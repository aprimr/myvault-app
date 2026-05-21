package service

import (
	"context"
	"fmt"
	"mime/multipart"
	"strings"
	"time"

	"github.com/aprimr/myvault/internal/constants"
	"github.com/aprimr/myvault/internal/logger"
	"github.com/aprimr/myvault/internal/mail"
	"github.com/aprimr/myvault/internal/models"
	"github.com/aprimr/myvault/internal/repository"
	"github.com/aprimr/myvault/internal/util"
	"github.com/jackc/pgx/v5/pgxpool"
)

func GetProfile(ctx context.Context, db *pgxpool.Pool, uid string) (*models.User, error) {
	// Call Repository
	user, err := repository.GetProfileByUID(ctx, db, uid)
	if err != nil {
		return nil, err
	}

	// Check if user is verified
	if !user.IsVerified {
		return nil, fmt.Errorf("email is not verified")
	}

	// Check if user is active
	if !user.IsActive {
		return nil, fmt.Errorf("account is inactive")
	}

	// Check if user is not deleted
	if user.IsDeleted {
		return nil, fmt.Errorf("account is deleted")
	}

	return user, nil
}

func UpdateProfilePicHandler(ctx context.Context, db *pgxpool.Pool, currProfileUrl string, file multipart.File, uid string) (string, error) {
	// Upload image file in cloudinary
	profileUrl, err := util.UploadImage(ctx, file, "profile_pic")
	if err != nil {
		logger.Error("Error uploading profile pic", err)
		return "", fmt.Errorf("failed to update profileurl")
	}

	// Add cloudinary image url in database
	err = repository.ChangeProfileUrl(ctx, db, uid, profileUrl)
	if err != nil {
		logger.Error("Error updating profile pic in db", err)
		return "", fmt.Errorf("failed updating profileurl")
	}

	// if currProfileUrl is not empty, delete old profile image from cloudinary
	if strings.TrimSpace(currProfileUrl) != "" {
		err := util.DeleteImage(ctx, currProfileUrl)
		if err != nil {
			logger.Error("Error deleting profile pic", err)
			return "", fmt.Errorf("failed to update profileurl")
		}
	}

	return profileUrl, nil
}

func DeleteProfilePic(ctx context.Context, db *pgxpool.Pool, uid string) error {
	// Get profile_url by id
	user, err := repository.GetProfileByUID(ctx, db, uid)
	if err != nil {
		return err
	}
	if user.ProfileUrl == "" {
		return fmt.Errorf("profilepic not set")
	}

	// Remove profile_url from user
	err = repository.DeleteProfileUrl(ctx, db, uid)
	if err != nil {
		return err
	}

	// Delete image from cloudinary
	err = util.DeleteImage(ctx, user.ProfileUrl)
	if err != nil {
		return err
	}

	return nil
}

func UpdateProfile(ctx context.Context, db *pgxpool.Pool, uid string, username, name *string) error {
	// if username is provided update it
	if username != nil {
		// Check if username is taken
		taken, err := repository.IsUsernameTaken(ctx, db, *username)
		if err != nil {
			return err
		}

		if taken {
			return fmt.Errorf("username is already taken")
		}

		// Update username in db
		err = repository.UpdateUsername(ctx, db, uid, *username)
		if err != nil {
			return err
		}
	}

	// Update name if provided
	if name != nil {
		// Update name in db
		err := repository.UpdateName(ctx, db, uid, *name)
		if err != nil {
			return err
		}
	}

	return nil
}

func ChangeEmail(ctx context.Context, db *pgxpool.Pool, mailService *mail.Service, uid, newEmail string) error {
	// Check if newEmail is already in use
	taken, err := repository.IsEmailTaken(ctx, db, newEmail)
	if err != nil {
		return err
	}
	if taken {
		return fmt.Errorf("email already in use")
	}

	// Generate OTP
	otp, err := util.GenerateOTP()
	if err != nil {
		logger.Error("ChangeEmail service: Generate OTP", err)
		return err
	}

	// Hash OTP
	otpHash := util.HashOTP(otp)

	// Store OTP in db
	err = repository.StoreOTP(ctx, db, uid, otpHash, constants.OTPPurposeChangeEmail)
	if err != nil {
		logger.Error("ChangeEmail service: Store OTP", err)
		return err
	}

	// Get User data
	user, err := repository.GetProfileByUID(ctx, db, uid)
	if err != nil {
		logger.Error("ChangeEmail service: GetProfile", err)
		return err
	}

	// Change email
	err = repository.UpdateEmail(ctx, db, uid, newEmail)
	if err != nil {
		logger.Error("ChangeEmail service: UpdateEmail", err)
		return err
	}

	// Send email
	curTime := time.Now().Format("2006-01-02 15:04")
	err = mailService.SendChangeEmailOTP(user.Name, newEmail, otp)
	err = mailService.SendChangeEmailAlert(user.Name, user.Email, newEmail, curTime)
	if err != nil {
		logger.Error("ChangeEmail service: SendMail", err)
		return err
	}

	return nil
}
