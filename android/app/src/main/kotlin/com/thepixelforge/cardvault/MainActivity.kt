package com.thepixelforge.cardvault

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth requires a FragmentActivity (AndroidX BiometricPrompt is
// fragment-based) — a plain FlutterActivity makes every authenticate() call
// fail silently.
class MainActivity : FlutterFragmentActivity()
