import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tcg_pokemon/pages/error_page.dart';
import 'package:tcg_pokemon/pages/login_pokemon.dart';
import 'package:tcg_pokemon/pages/register_pokemon.dart';
import 'package:tcg_pokemon/pages/loading_pokemon.dart';
import 'package:tcg_pokemon/pages/home_dashboard.dart';
import 'package:tcg_pokemon/pages/sets_page.dart';
import 'package:tcg_pokemon/pages/cards_page.dart';
import 'package:tcg_pokemon/pages/favorites_page.dart';
import 'package:tcg_pokemon/pages/settings_page.dart';
import 'package:tcg_pokemon/pages/topup_page.dart';
import 'package:tcg_pokemon/pages/my_cards_page.dart';
import 'package:tcg_pokemon/pages/purchase_result_page.dart';
import 'package:tcg_pokemon/providers/auth_provider.dart';
import 'package:tcg_pokemon/providers/card_provider.dart';
import 'package:tcg_pokemon/routes/app_routes.dart';

bool hasShownLoading = false;

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.homePath,
  errorBuilder: (context, state) =>
    const ErrorPage(), // Halaman error untuk route yang tidak ditemukan
  redirect: (context, state) {
    // Cek status login
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final isGoingToLogin = state.matchedLocation == AppRoutes.loginPath;
    final isGoingToRegister = state.matchedLocation == AppRoutes.registerPath;
    final isGoingToLoading = state.matchedLocation == AppRoutes.loadingPath;

    // Force loading screen if it hasn't been shown in this session
    if (!hasShownLoading && !isGoingToLoading) {
      return '${AppRoutes.loadingPath}?redirect=${state.matchedLocation}';
    }

    // Jika belum login dan mencoba akses halaman proteksi, arahkan ke login
    if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToLoading) {
      return AppRoutes.loginPath;
    }

    // Jika sudah login dan mencoba akses login/register, arahkan ke home
    if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
      return AppRoutes.homePath;
    }

    return null;
  },
  routes: [
    GoRoute(
      name: AppRoutes.loginName,
      path: AppRoutes.loginPath,
      builder: (context, state) {
        return const PokemonTcgLoginApp();
      }
    ),
    GoRoute(
      name: AppRoutes.registerName,
      path: AppRoutes.registerPath,
      builder: (context, state) {
        return const PokemonTcgRegisterApp();
      }
    ),
    GoRoute(
      name: AppRoutes.loadingName,
      path: AppRoutes.loadingPath,
      builder: (context, state) {
        return const LoadingPokemon();
      }
    ),
    GoRoute(
      name: AppRoutes.homeName,
      path: AppRoutes.homePath,
      builder: (context, state) {
        return const HomeScreen();
      }
    ),
    GoRoute(
      name: AppRoutes.setsName,
      path: AppRoutes.setsPath,
      builder: (context, state) {
        return const SetsPage();
      }
    ),
    GoRoute(
      name: AppRoutes.cardsName,
      path: AppRoutes.cardsPath,
      builder: (context, state) {
        return const CardsPage();
      }
    ),
    GoRoute(
      name: AppRoutes.favoritesName,
      path: AppRoutes.favoritesPath,
      builder: (context, state) {
        return const FavoritesPage();
      }
    ),
    GoRoute(
      name: AppRoutes.settingsName,
      path: AppRoutes.settingsPath,
      builder: (context, state) {
        return const SettingsPage();
      }
    ),
    GoRoute(
      name: AppRoutes.topupName,
      path: AppRoutes.topupPath,
      builder: (context, state) {
        return const TopupPage();
      }
    ),
    GoRoute(
      name: AppRoutes.myCardsName,
      path: AppRoutes.myCardsPath,
      builder: (context, state) {
        return const MyCardsPage();
      }
    ),
    GoRoute(
      name: AppRoutes.purchaseResultName,
      path: AppRoutes.purchaseResultPath,
      builder: (context, state) {
        final purchaseResult = state.extra as PurchaseResult?;
        if (purchaseResult == null) {
          return const ErrorPage();
        }
        return PurchaseResultPage(purchaseResult: purchaseResult);
      }
    ),
  ],
);

// Ini Yang Dikumpulkan
