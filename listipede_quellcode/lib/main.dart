import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:listipede/presentation/list_users_screen.dart';
import 'config/firebase_options.dart';
import 'presentation/list_of_lists_screen.dart';
import 'presentation/shopping_list_screen.dart';
import 'domain/entities/shopping_list.dart';
import 'presentation/shop_picker_screen.dart';
import 'presentation/shopping_mode_screen.dart';
import 'config/style.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'presentation/user_profile_screen.dart';
import 'presentation/my_products_screen.dart';
import 'presentation/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    // ... other providers
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return PlatformProvider(
      builder: (context) => PlatformTheme(
        builder: (context) => PlatformApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          title: 'Listipede',
          material: (_, __) => MaterialAppData(
            theme: listiTheme,
          ),
          initialRoute: FirebaseAuth.instance.currentUser == null
              ? '/sign-in'
              : '/listoflists',
          routes: {
            '/': (context) => const ListOfListsScreen(),
            '/sign-in': (context) => SignInScreen(
                  providers: providers,
                  actions: [
                    AuthStateChangeAction<SignedIn>((context, state) {
                      Navigator.pushReplacementNamed(context, '/listoflists');
                    }),
                  ],
                ),
            '/profile': (context) => UserProfileScreen(providers: providers),
            '/listoflists': (context) => const ListOfListsScreen(),
            '/list-users': (context) => ListUsersScreen(
                  shoppingList: ModalRoute.of(context)?.settings.arguments
                      as ShoppingList,
                ),
            '/shopping-list': (context) => ShoppingListScreen(
                  shoppingList: ModalRoute.of(context)?.settings.arguments
                      as ShoppingList,
                ),
            '/shopping-mode': (context) => ShoppingModeScreen(
                  shoppingList: ModalRoute.of(context)?.settings.arguments
                      as ShoppingList,
                ),
            '/shop-picker': (context) => ShopPickerScreen(
                  listId: ModalRoute.of(context)?.settings.arguments as String,
                ),
            '/my-products': (context) => MyProductsScreen(),
            '/about': (context) => AboutScreen(),
          },
        ),
      ),
    );
  }
}
