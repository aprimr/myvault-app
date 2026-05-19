package util

import (
	"context"
	"fmt"
	"mime/multipart"
	"os"
	"strings"

	"github.com/cloudinary/cloudinary-go/v2"
	"github.com/cloudinary/cloudinary-go/v2/api/uploader"
)

var cld *cloudinary.Cloudinary

func InitCloudinary() error {
	var err error

	cld, err = cloudinary.NewFromParams(
		os.Getenv("CLOUDINARY_CLOUD_NAME"),
		os.Getenv("CLOUDINARY_API_KEY"),
		os.Getenv("CLOUDINARY_API_SECRET"),
	)

	if err != nil {
		return err
	}

	return nil
}

// ExtractPublicID extracts the Cloudinary public_id from image URL
// by removing the domain, version, and file extension and returns publicId
func ExtractPublicID(url string) string {
	if url == "" {
		return ""
	}

	// Get part after /upload/
	parts := strings.Split(url, "/upload/")
	if len(parts) < 2 {
		return ""
	}

	path := parts[1]

	// Remove version from url
	slashIndex := strings.Index(path, "/")
	if slashIndex != -1 && strings.HasPrefix(path[:slashIndex], "v") {
		path = path[slashIndex+1:]
	}

	// Remove file extension
	path = strings.Split(path, ".")[0]

	return path
}

// UploadImage takes file and folder name and uploads the image to cloudinary
// And returns imageURL and error
func UploadImage(ctx context.Context, file multipart.File, folder string) (string, error) {
	if cld == nil {
		return "", fmt.Errorf("cloudinary not initialized")
	}

	res, err := cld.Upload.Upload(ctx, file, uploader.UploadParams{
		Folder: folder,
	})

	if err != nil {
		return "", err
	}

	return res.SecureURL, nil
}

// DeleteImage takes the imageURL extracts publicId from url and deletes the file
func DeleteImage(ctx context.Context, imageURL string) error {
	if cld == nil {
		return fmt.Errorf("cloudinary not initialized")
	}

	if strings.TrimSpace(imageURL) == "" {
		return fmt.Errorf("empty image url")
	}

	publicID := ExtractPublicID(imageURL)

	_, err := cld.Upload.Destroy(ctx, uploader.DestroyParams{
		PublicID: publicID,
	})

	if err != nil {
		return err
	}

	return nil
}
