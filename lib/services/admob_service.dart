import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

enum AdType {
  repoView, // Al ver un repositorio
  cloneGenerated, // Al generar comando de clonación
  githubRedirect, // Al ir a GitHub
}

class AdMobService {
  static RewardedAd? _rewardedAd;
  static InterstitialAd? _interstitialAd;
  static bool _isRewardedAdLoaded = false;
  static bool _isInterstitialAdLoaded = false;
  static bool _isInitialized = false;

  // IDs de prueba - reemplaza con tus IDs reales en producción
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // Configuración de frecuencia de anuncios
  static final Map<AdType, DateTime?> _lastAdShown = {
    AdType.repoView: null,
    AdType.cloneGenerated: null,
    AdType.githubRedirect: null,
  };

  static const Duration _minTimeBetweenAds = Duration(minutes: 2);

  static Future<void> initializeAds() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      await _loadAllAds();
      _isInitialized = true;
      debugPrint('✅ AdMob inicializado correctamente');
    } catch (e) {
      debugPrint('❌ Error inicializando AdMob: $e');
    }
  }

  static Future<void> _loadAllAds() async {
    await Future.wait([_loadRewardedAd(), _loadInterstitialAd()]);
  }

  static Future<void> _loadRewardedAd() async {
    if (_rewardedAd != null) {
      _rewardedAd!.dispose();
    }

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          _setRewardedAdCallbacks();
          debugPrint('✅ Anuncio de recompensa cargado');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          debugPrint(
            '❌ Error cargando anuncio de recompensa: ${error.message}',
          );
          // Reintentar después de 30 segundos
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  static Future<void> _loadInterstitialAd() async {
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
    }

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _setInterstitialAdCallbacks();
          debugPrint('✅ Anuncio intersticial cargado');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialAdLoaded = false;
          _interstitialAd = null;
          debugPrint('❌ Error cargando anuncio intersticial: ${error.message}');
          // Reintentar después de 30 segundos
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  static void _setRewardedAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint('📺 Anuncio de recompensa mostrado');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        _loadRewardedAd(); // Cargar el siguiente
        debugPrint('❌ Anuncio de recompensa cerrado');
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        _loadRewardedAd();
        debugPrint('❌ Error mostrando anuncio de recompensa: ${error.message}');
      },
    );
  }

  static void _setInterstitialAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('📺 Anuncio intersticial mostrado');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        _loadInterstitialAd(); // Cargar el siguiente
        debugPrint('❌ Anuncio intersticial cerrado');
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        _loadInterstitialAd();
        debugPrint('❌ Error mostrando anuncio intersticial: ${error.message}');
      },
    );
  }

  // 🎯 CORRECCIÓN: Cambiar tipo de retorno y manejo de callbacks
  static Future<bool> showAdForAction({
    required AdType adType,
    required BuildContext context,
    required VoidCallback onAdCompleted,
    VoidCallback? onAdSkipped,
    bool forceShow = false,
  }) async {
    if (!_isInitialized) {
      await initializeAds();
    }

    // Verificar si debe mostrar anuncio según frecuencia
    if (!forceShow && !_shouldShowAd(adType)) {
      onAdCompleted();
      return true;
    }

    switch (adType) {
      case AdType.repoView:
        return await _showInterstitialAd(
          context: context,
          onAdCompleted: onAdCompleted,
          onAdSkipped: onAdSkipped,
          adType: adType,
        );

      case AdType.cloneGenerated:
        return await _showRewardedAd(
          context: context,
          onAdCompleted: onAdCompleted,
          onAdSkipped: onAdSkipped,
          adType: adType,
        );

      case AdType.githubRedirect:
        return await _showInterstitialAd(
          context: context,
          onAdCompleted: onAdCompleted,
          onAdSkipped: onAdSkipped,
          adType: adType,
        );
    }
  }

  static Future<bool> _showInterstitialAd({
    required BuildContext context,
    required VoidCallback onAdCompleted,
    VoidCallback? onAdSkipped,
    required AdType adType,
  }) async {
    if (_interstitialAd != null && _isInterstitialAdLoaded) {
      _showLoadingDialog(context, adType);

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar loading
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
          _updateLastAdShown(adType);
          onAdCompleted();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar loading
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
          // 🎯 CORRECCIÓN: Llamar callback por separado
          if (onAdSkipped != null) {
            onAdSkipped();
          } else {
            onAdCompleted();
          }
        },
      );

      await _interstitialAd!.show();
      return true;
    } else {
      _showNoAdDialog(context, onAdCompleted, onAdSkipped);
      return false;
    }
  }

  static Future<bool> _showRewardedAd({
    required BuildContext context,
    required VoidCallback onAdCompleted,
    VoidCallback? onAdSkipped,
    required AdType adType,
  }) async {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      _showLoadingDialog(context, adType);

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar loading
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          Navigator.of(context, rootNavigator: true).pop(); // Cerrar loading
          ad.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          _loadRewardedAd();
          // 🎯 CORRECCIÓN: Llamar callback por separado
          if (onAdSkipped != null) {
            onAdSkipped();
          } else {
            onAdCompleted();
          }
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          _updateLastAdShown(adType);
          onAdCompleted();
        },
      );
      return true;
    } else {
      _showNoAdDialog(context, onAdCompleted, onAdSkipped);
      return false;
    }
  }

  static bool _shouldShowAd(AdType adType) {
    final lastShown = _lastAdShown[adType];
    if (lastShown == null) return true;

    final timeDifference = DateTime.now().difference(lastShown);
    return timeDifference >= _minTimeBetweenAds;
  }

  static void _updateLastAdShown(AdType adType) {
    _lastAdShown[adType] = DateTime.now();
  }

  static void _showLoadingDialog(BuildContext context, AdType adType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF262729),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3489FE)),
                ),
                const SizedBox(height: 16),
                Text(
                  _getLoadingMessage(adType),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preparando contenido...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showNoAdDialog(
    BuildContext context,
    VoidCallback onAdCompleted,
    VoidCallback? onAdSkipped,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262729),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '📺 Sin anuncios disponibles',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'No hay anuncios disponibles en este momento. ¿Continuar de todas formas?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 🎯 CORRECCIÓN: Verificar si callback existe antes de llamar
                if (onAdSkipped != null) {
                  onAdSkipped();
                }
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onAdCompleted();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3489FE),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static String _getLoadingMessage(AdType adType) {
    switch (adType) {
      case AdType.repoView:
        return 'Cargando repositorio...';
      case AdType.cloneGenerated:
        return 'Generando comando de clonación...';
      case AdType.githubRedirect:
        return 'Preparando enlace a GitHub...';
    }
  }

  // Getters para verificar estado
  static bool get isRewardedAdReady =>
      _isRewardedAdLoaded && _rewardedAd != null;
  static bool get isInterstitialAdReady =>
      _isInterstitialAdLoaded && _interstitialAd != null;
  static bool get isInitialized => _isInitialized;

  // Método para precargar anuncios manualmente
  static Future<void> preloadAds() async {
    if (!_isInitialized) return;

    if (!_isRewardedAdLoaded) {
      await _loadRewardedAd();
    }
    if (!_isInterstitialAdLoaded) {
      await _loadInterstitialAd();
    }
  }

  // Limpieza de recursos
  static void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd = null;
    _interstitialAd = null;
    _isRewardedAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isInitialized = false;
    debugPrint('🧹 AdMobService limpiado');
  }
}
