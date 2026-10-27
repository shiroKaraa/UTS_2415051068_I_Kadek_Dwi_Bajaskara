import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpFaq)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ExpansionTile(
            title: Text(l10n.faq1Title),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l10n.faq1Desc),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(l10n.faq2Title),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l10n.faq2Desc),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(l10n.faq3Title),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l10n.faq3Desc),
              ),
            ],
          ),
          ExpansionTile(
            title: Text(l10n.faq4Title),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l10n.faq4Desc),
              ),
            ],
          ),
        ],
      ),
    );
  }
}