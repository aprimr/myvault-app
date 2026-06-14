import 'package:app/core/app.dart';
import 'package:app/core/routes.dart';
import 'package:app/services/auth.dart';
import 'package:app/services/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/core/service_locator.dart';
import 'package:app/widgets/app_loader.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  bool isUploadingPhoto = false;
  Map<String, dynamic>? user;

  late final ProfileService profileService;
  final AuthService authService = App.authService;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    profileService = ProfileService(apiClient);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => isLoading = true);
      final data = await profileService.getProfile();
      if (!mounted) return;
      setState(() {
        user = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AppSnackbar.show(
        context,
        message: "Failed to load profile",
        isError: true,
      );
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    // Request permission
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final status = await permission.request();

    if (!status.isGranted) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: "Permission denied. Please allow access in settings.",
        isError: true,
      );
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );

    if (picked == null) return;

    setState(() => isUploadingPhoto = true);

    try {
      final newUrl = await profileService.updatePhoto(
        filePath: picked.path,
        currentProfileUrl: user?["profile_url"] ?? "",
      );

      if (!mounted) return;
      setState(() {
        user = {...?user, "profile_url": newUrl};
        isUploadingPhoto = false;
      });

      AppSnackbar.show(context, message: "Photo updated");
    } catch (e) {
      if (!mounted) return;
      setState(() => isUploadingPhoto = false);
      AppSnackbar.show(
        context,
        message: "Failed to update photo",
        isError: true,
      );
    }
  }

  Future<void> _deletePhoto() async {
    setState(() => isUploadingPhoto = true);

    try {
      await profileService.deletePhoto();
      if (!mounted) return;
      setState(() {
        user = {...?user, "profile_url": ""};
        isUploadingPhoto = false;
      });
      AppSnackbar.show(context, message: "Photo removed");
    } catch (e) {
      if (!mounted) return;
      setState(() => isUploadingPhoto = false);
      AppSnackbar.show(
        context,
        message: "Failed to remove photo",
        isError: true,
      );
    }
  }

  void _showPhotoOptions() {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPhoto = (user?["profile_url"] ?? "").isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withAlpha(40),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Profile Photo",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            _PhotoOption(
              icon: HugeIcons.strokeRoundedCamera01,
              label: "Take a Photo",
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadPhoto(ImageSource.camera);
              },
            ),

            const SizedBox(height: 10),

            _PhotoOption(
              icon: HugeIcons.strokeRoundedImage01,
              label: "Choose from Gallery",
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadPhoto(ImageSource.gallery);
              },
            ),

            if (hasPhoto) ...[
              const SizedBox(height: 10),
              _PhotoOption(
                icon: HugeIcons.strokeRoundedImageDelete02,
                label: "Remove Photo",
                color: colorScheme.error,
                onTap: () {
                  Navigator.pop(ctx);
                  _deletePhoto();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditSheet() {
    final nameCtrl = TextEditingController(text: user?["name"] ?? "");
    final usernameCtrl = TextEditingController(text: user?["username"] ?? "");
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withAlpha(40),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Edit Profile",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _SheetField(label: "Name", controller: nameCtrl),
            const SizedBox(height: 14),
            _SheetField(label: "Username", controller: usernameCtrl),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    final updated = await profileService.updateProfile(
                      name: nameCtrl.text.trim(),
                      username: usernameCtrl.text.trim(),
                    );
                    if (!mounted) return;
                    setState(() => user = updated);
                    AppSnackbar.show(context, message: "Profile updated");
                  } catch (e) {
                    if (!mounted) return;
                    AppSnackbar.show(
                      context,
                      message: "Failed to update profile",
                      isError: true,
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save Changes",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileUrl = user?["profile_url"] ?? "";

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: isLoading
                ? const SizedBox()
                : RefreshIndicator(
                    onRefresh: _loadProfile,
                    child: ListView(
                      children: [
                        // AppBar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Your Profile",
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ProfilePic
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 106,
                                height: 106,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary.withAlpha(30),
                                  border: Border.all(
                                    color: colorScheme.primary,
                                    width: 3.5,
                                  ),
                                  image: profileUrl.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(profileUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: profileUrl.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(22),
                                        child: Image.network(
                                          'https://res.cloudinary.com/dbkl5kiqg/image/upload/1_wqcisl.png',
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : null,
                              ),

                              // Edit overlay
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: isUploadingPhoto
                                      ? null
                                      : _showPhotoOptions,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withAlpha(26),
                                    ),
                                    child: Center(
                                      child: isUploadingPhoto
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : HugeIcon(
                                              icon:
                                                  HugeIcons.strokeRoundedEdit02,
                                              size: 22,
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Details
                        Column(
                          children: [
                            Text(
                              user?["name"] ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "@${user?["username"] ?? ""}",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: colorScheme.onSurface.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Edit profile btn
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: GestureDetector(
                            onTap: _showEditSheet,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  "Edit Profile",
                                  style: GoogleFonts.poppins(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Account Info
                        _SectionLabel(label: "Account Info"),
                        const SizedBox(height: 10),

                        _InfoTile(
                          icon: HugeIcons.strokeRoundedMail01,
                          label: "Email",
                          value: user?["email"] ?? "",
                          trailing: _VerifiedBadge(
                            verified: user?["is_verified"] == true,
                          ),
                        ),

                        _InfoTile(
                          icon: HugeIcons.strokeRoundedUser,
                          label: "Username",
                          value: "@${user?["username"] ?? ""}",
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: user?["username"] ?? ""),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Account Actions
                        _SectionLabel(label: "Account Actions"),
                        const SizedBox(height: 10),

                        _ActionTile(
                          icon: HugeIcons.strokeRoundedLockPassword,
                          label: "Change Password",
                          onTap: () {},
                        ),

                        _ActionTile(
                          icon: HugeIcons.strokeRoundedMailEdit01,
                          label: "Update Email",
                          onTap: () {},
                        ),

                        const SizedBox(height: 16),

                        // App Actions
                        _SectionLabel(label: "App Actions"),
                        const SizedBox(height: 10),

                        _ActionTile(
                          icon: HugeIcons.strokeRoundedMatrix,
                          label: "Update App Pin",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.setupPinRoute,
                            );
                          },
                        ),

                        _ActionTile(
                          icon: HugeIcons.strokeRoundedLogout01,
                          label: "Log Out",
                          color: colorScheme.error,
                          onTap: () {
                            authService.logout();
                            _loadProfile();
                          },
                        ),

                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
          ),
        ),

        if (isLoading)
          const Positioned.fill(
            child: AppLoader(message: "Fetching profile..."),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withAlpha(110),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _SheetField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: colorScheme.onSurface.withAlpha(140),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            hoverColor: Theme.of(context).scaffoldBackgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final bool verified;
  const _VerifiedBadge({required this.verified});

  @override
  Widget build(BuildContext context) {
    final color = verified ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        verified ? "Verified" : "Unverified",
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              HugeIcon(icon: icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withAlpha(225),
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
              if (onTap != null && trailing == null)
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCopy01,
                  color: colorScheme.onSurface.withAlpha(80),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: effectiveColor.withAlpha(12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              HugeIcon(icon: icon, color: effectiveColor, size: 20),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: effectiveColor,
                ),
              ),
              const Spacer(),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: effectiveColor.withAlpha(150),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: effectiveColor.withAlpha(16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            HugeIcon(icon: icon, color: effectiveColor, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
