import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/design_system/glass_theme.dart';
import 'routing/app_router.dart';

class VaultNoteApp extends ConsumerWidget {
  const VaultNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'VaultNote',
      theme: GlassTheme.lightTheme,
      darkTheme: GlassTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

class TestGlassScreen extends ConsumerWidget {
  const TestGlassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceTransparency = ref.watch(reduceTransparencyProvider);

    return Scaffold(
      body: GlassTheme.buildBackground(
        isDark: isDark,
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative background elements to show off the blur
              Positioned(
                top: 100,
                left: 50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.5),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: 50,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.withOpacity(0.4),
                  ),
                ),
              ),
              
              // Actual UI
              Column(
                children: [
                  // App Bar / Top Nav (Tier 1)
                  GlassSurface(
                    tier: GlassTier.tier1,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    margin: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'VaultNote',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Text('Reduce Transparency'),
                            Switch(
                              value: reduceTransparency,
                              onChanged: (val) => ref.read(reduceTransparencyProvider.notifier).state = val,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Main Content Area
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GlassSurface(
                            tier: GlassTier.tier2,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Note Title $index',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'This is an example of a note card using Tier 2 glassmorphism. It has a medium blur and looks stunning over gradients.',
                                ),
                                const SizedBox(height: 16),
                                // Tags (Tier 3)
                                Row(
                                  children: [
                                    GlassSurface(
                                      tier: GlassTier.tier3,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Text('Flutter'),
                                    ),
                                    const SizedBox(width: 8),
                                    GlassSurface(
                                      tier: GlassTier.tier3,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      borderRadius: BorderRadius.circular(8),
                                      child: const Text('Design'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
