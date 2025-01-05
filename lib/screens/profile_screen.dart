import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isSignedIn = true;
  String fullName = '';
  String userName = '';
  int favoriteCandiCount = 0;
  File? image;

  // Fungsi untuk Sign In
  void signIn() {
    Navigator.pushNamed(context, '/signin');
  }

  // Fungsi untuk Logout, menghapus data yang tersimpan
  Future<void> logOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', false);

    Navigator.pushReplacementNamed(context, '/signin');
  }

  // Fungsi untuk mengambil gambar
  Future<void> selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage =
        await picker.pickImage(source: ImageSource.camera);

    if (selectedImage != null) {
      setState(() {
        image = File(selectedImage.path);
        print(
            "Selected image path: ${selectedImage.path}"); // Set the image file to the state
      });
    }
  }

  // Fungsi untuk menyimpan jumlah favorite
  Future<void> _saveFavoriteCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('favoriteCandiCount', favoriteCandiCount);
  }

  // Fungsi untuk mengedit user name
  Future<void> _editUserName() async {
    final TextEditingController controller =
        TextEditingController(text: userName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Enter new user name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                setState(() {
                  userName = controller.text;
                });
                await prefs.setString('currentUsername', userName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk mengenkripsi teks
  String encryptText(String text) {
    return base64.encode(utf8.encode(text));
  }

  // Fungsi untuk mendekripsi teks
  String decryptText(String text) {
    return utf8.decode(base64.decode(text));
  }

  // Fungsi untuk mengedit full name
  Future<void> _editFullName() async {
    final TextEditingController controller =
        TextEditingController(text: fullName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Full Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Enter new full name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final String newName = controller.text;
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final String encryptedName = encryptText(newName);

                setState(() {
                  fullName = newName;
                });

                await prefs.setString('currentName', encryptedName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Mengecek status login saat pertama kali membuka layar
    _loadProfileData(); // Memuat data profil pengguna
  }

  // Mengecek status login dari SharedPreferences
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? signedIn = prefs.getBool('isSignedIn');
    setState(() {
      isSignedIn = signedIn ?? false;
    });
    if (!isSignedIn) {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  Future<Map<String, String>> _retrieveAndDecryptDataFromPrefs(
    SharedPreferences sharedPreferences,
  ) async {
    try {
      final encryptedUsername = sharedPreferences.getString('username');
      final encryptedPassword = sharedPreferences.getString('fullname');
      final keyString = sharedPreferences.getString('key');
      final ivString = sharedPreferences.getString('iv');

      if (encryptedUsername == null ||
          encryptedPassword == null ||
          keyString == null ||
          ivString == null) {
        throw Exception('Missing credentials in SharedPreferences.');
      }

      final encrypt.Key key = encrypt.Key.fromBase64(keyString);
      final encrypt.IV iv = encrypt.IV.fromBase64(ivString);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decryptedUsername = encrypter.decrypt64(encryptedUsername, iv: iv);
      final decryptedPassword = encrypter.decrypt64(encryptedPassword, iv: iv);

      return {'username': decryptedUsername, 'fullname': decryptedPassword};
    } catch (e) {
      print('Decryption failed: $e');
      return {};
    }
  }

  // Memuat data profil pengguna dari SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = await _retrieveAndDecryptDataFromPrefs(prefs);

    if (data.isNotEmpty) {
      final decryptedUsername = data['username'];
      final decryptedPassword = data['fullname'];
      setState(() {
        fullName = decryptedPassword ?? "Fullname tidak ditemukan.";
        userName =
            decryptedUsername ?? "Username tidak ditemukan."; // Ambil username
        favoriteCandiCount =
            prefs.getInt('favoriteCandiCount') ?? 0; // Ambil count favorite
      });
    }
  }

  // Fungsi untuk menyimpan data saat user mendaftar
  Future<void> saveProfileData(String name, String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'currentName', encryptText(name)); // Simpan nama lengkap terenkripsi
    await prefs.setString('currentUsername', username); // Simpan username
    await prefs.setBool('isSignedIn', true); // Set status login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bagian header dengan background ungu dan avatar
          Stack(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                color: Color.fromRGBO(210, 190, 223, 1.0),
              ),
              Positioned(
                top: 125 - 50, // Atur agar avatar berada di tengah area ungu
                left: MediaQuery.of(context).size.width / 2 - 50,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(210, 190, 223, 1.0),
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: image == null
                            ? const AssetImage('images/placeholder_image.png')
                            : FileImage(image!) as ImageProvider,
                      ),
                    ),
                    if (isSignedIn)
                      IconButton(
                        onPressed: selectImage,
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.deepPurple[50],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bagian konten (UserName, Name, Favorite)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // UserName
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(210, 190, 223, 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: const Row(
                            children: [
                              SizedBox(width: 8),
                              Text(
                                'User Name ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ': $userName',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.deepPurple),
                          onPressed: _editUserName,
                        ),
                      ],
                    ),
                  ),

                  // Full Name
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(210, 190, 223, 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: const Row(
                            children: [
                              SizedBox(width: 8),
                              Text(
                                'Name ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ': $fullName',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.deepPurple),
                          onPressed: _editFullName,
                        ),
                      ],
                    ),
                  ),

                  // Favorite
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(210, 190, 223, 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: const Row(
                            children: [
                              SizedBox(width: 8),
                              Text(
                                'Favorite ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            favoriteCandiCount > 0
                                ? ': $favoriteCandiCount'
                                : ': No Favorites',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tombol Sign In / Log Out
                  if (isSignedIn)
                    TextButton(
                      onPressed: logOut,
                      child: const Text('Log Out'),
                    )
                  else
                    TextButton(
                      onPressed: signIn,
                      child: const Text('Sign in'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
