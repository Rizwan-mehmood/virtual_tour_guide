// lib/helper/google_drive_helper.dart

import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class GoogleDriveHelper {
  /// The Drive scopes we need: file creation and read access.
  static const _scopes = [drive.DriveApi.driveFileScope];

  /// Load the service account JSON from assets.
  static Future<ServiceAccountCredentials> _loadCredentials() async {
    final json = await rootBundle.loadString(
      'assets/drive_service_account.json',
    );
    return ServiceAccountCredentials.fromJson(json);
  }

  /// Upload [imageFile] to Google Drive, make it public, and return its webContentLink.
  static Future<String> uploadImageToGoogleDrive(File imageFile) async {
    // 1) Authenticate via Service Account
    final creds = await _loadCredentials();
    final client = await clientViaServiceAccount(creds, _scopes);
    final driveApi = drive.DriveApi(client);

    // 2) Prepare the Drive file metadata
    final fileName = basename(imageFile.path);
    final driveFile = drive.File()..name = fileName;

    // 3) Upload the file contents
    final media = drive.Media(imageFile.openRead(), imageFile.lengthSync());
    final created = await driveApi.files.create(driveFile, uploadMedia: media);

    // 4) Make it publicly readable
    await driveApi.permissions.create(
      drive.Permission()
        ..type = 'anyone'
        ..role = 'reader',
      created.id!,
    );

    final file =
        await driveApi.files.get(created.id!, $fields: 'webContentLink')
            as drive.File;
    return file.webContentLink ?? '';
  }
}
