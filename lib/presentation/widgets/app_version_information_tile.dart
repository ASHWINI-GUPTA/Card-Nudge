import 'package:card_nudge/helper/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helper/emoji_helper.dart';
import 'emoji_celebration_animation.dart';

class AppVersionInformationTile extends StatefulWidget {
  @override
  State<AppVersionInformationTile> createState() =>
      _AppVersionInformationTileState();
}

class _AppVersionInformationTileState extends State<AppVersionInformationTile> {
  int _tapCount = 0;
  Key? _blastKey;

  void _handleTap() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 3) {
        _blastKey = UniqueKey();
        _tapCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ListTile(
          title: Text(context.l10n.appVersion),
          leading: Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          subtitle: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.version);
              } else if (snapshot.hasError) {
                return Text('${context.l10n.versionError}: ${snapshot.error}');
              }
              return Text(context.l10n.loadingVersion);
            },
          ),
          onTap: _handleTap,
        ),
        if (_blastKey != null)
          Positioned.fill(
            child: IgnorePointer(
              child: EmojiCelebrationAnimation(
                key: _blastKey,
                count: 24,
                emojis: blastEmojiList,
                duration: const Duration(milliseconds: 1500),
                minDistance: 200,
                maxDistance: 600,
                onBlastEnd: () {
                  setState(() {
                    _blastKey = null;
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}
