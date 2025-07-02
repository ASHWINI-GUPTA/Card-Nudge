import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constants/app_strings.dart';
import '../../helper/emoji_helper.dart';
import 'emoji_blast.dart';

class VersionListTile extends StatefulWidget {
  @override
  State<VersionListTile> createState() => _VersionListTileState();
}

class _VersionListTileState extends State<VersionListTile> {
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
          title: Text(AppStrings.appVersion),
          subtitle: FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.version);
              } else if (snapshot.hasError) {
                return Text('${AppStrings.versionError}: ${snapshot.error}');
              }
              return const Text(AppStrings.loadingVersion);
            },
          ),
          onTap: _handleTap,
        ),
        if (_blastKey != null)
          Positioned.fill(
            child: IgnorePointer(
              child: EmojiBlast(
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
