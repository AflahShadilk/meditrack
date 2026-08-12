import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'design_system_preview_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('MediTrack')),
        body: const Center(
          child: Text('Module 02: App Foundation Ready'),
        ),
      ),
    ),
    GoRoute(
      path: '/design-system',
      builder: (context, state) => const DesignSystemPreviewPage(),
    ),
  ],
);
