import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class EncryptionService {
  final FlutterSecureStorage _secureStorage;
  static const String _encryptionKeyName = 'vaultnote_master_key';

  encrypt.Key? _masterKey;

  EncryptionService(this._secureStorage);

  /// Initializes the encryption service by retrieving or generating the master key
  Future<void> initialize() async {
    String? storedKey = await _secureStorage.read(key: _encryptionKeyName);
    
    if (storedKey == null) {
      // Generate a new 32-byte (256-bit) key for AES-256
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
      storedKey = base64UrlEncode(keyBytes);
      await _secureStorage.write(key: _encryptionKeyName, value: storedKey);
    }
    
    _masterKey = encrypt.Key(base64Url.decode(storedKey));
  }

  /// Encrypts a string using AES-256 (CBC mode is default for `encrypt` package)
  String encryptText(String plainText) {
    if (_masterKey == null) throw Exception("EncryptionService not initialized");
    
    final encrypter = encrypt.Encrypter(encrypt.AES(_masterKey!));
    // Generate a secure random IV for each encryption
    final iv = encrypt.IV.fromSecureRandom(16);
    
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    
    // Store IV along with encrypted data (IV + : + ciphertext)
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a string
  String decryptText(String encryptedData) {
    if (_masterKey == null) throw Exception("EncryptionService not initialized");
    
    final parts = encryptedData.split(':');
    if (parts.length != 2) throw Exception("Invalid encrypted data format");
    
    final iv = encrypt.IV.fromBase64(parts[0]);
    final cipherText = parts[1];
    
    final encrypter = encrypt.Encrypter(encrypt.AES(_masterKey!));
    final decrypted = encrypter.decrypt64(cipherText, iv: iv);
    
    return decrypted;
  }

  /// Encrypts raw bytes (for files, images, PDFs)
  Uint8List encryptBytes(Uint8List plainBytes) {
    if (_masterKey == null) throw Exception("EncryptionService not initialized");
    
    final encrypter = encrypt.Encrypter(encrypt.AES(_masterKey!));
    final iv = encrypt.IV.fromSecureRandom(16);
    
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);
    
    // Prefix the IV (16 bytes) to the encrypted payload
    final payload = BytesBuilder()
      ..add(iv.bytes)
      ..add(encrypted.bytes);
      
    return payload.toBytes();
  }

  /// Decrypts raw bytes
  Uint8List decryptBytes(Uint8List encryptedPayload) {
    if (_masterKey == null) throw Exception("EncryptionService not initialized");
    if (encryptedPayload.length < 16) throw Exception("Invalid encrypted payload");
    
    // Extract the IV (first 16 bytes)
    final ivBytes = encryptedPayload.sublist(0, 16);
    final cipherBytes = encryptedPayload.sublist(16);
    
    final iv = encrypt.IV(ivBytes);
    final encrypter = encrypt.Encrypter(encrypt.AES(_masterKey!));
    
    final decrypted = encrypter.decryptBytes(encrypt.Encrypted(cipherBytes), iv: iv);
    return Uint8List.fromList(decrypted);
  }
}
