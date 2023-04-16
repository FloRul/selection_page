import 'package:flutter/material.dart';

class HubListView extends StatelessWidget {
  const HubListView({
    required this.tileBuilder,
    required this.itemCount,
    super.key,
    this.shrinkWrap = true,
  });

  final HubListTile Function(int index) tileBuilder;
  final int itemCount;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    var iconSpace = false;
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      itemBuilder: (context, index) {
        final tile = tileBuilder(index);
        iconSpace = tile.leadingIcon != null;
        return tile;
      },
      itemCount: itemCount,
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 0,
        indent: 16 +
            (iconSpace
                ? ListTileIcon.iconSize + HubListTile.titleGap
                : 0), // the padding of the tile + potentially the size of the leading icon
      ),
    );
  }
}

class HubListTile extends StatelessWidget {
  const HubListTile({
    required this.title,
    super.key,
    this.additionalInfo = '',
    this.leadingIcon,
    this.onTap,
    this.isActive = true,
    this.selected = false,
    this.trailing,
  });
  final String title;
  final bool isActive;
  final bool selected;
  final String? additionalInfo;
  final ListTileIcon? leadingIcon;
  final VoidCallback? onTap;
  final Widget? trailing;
  static const titleGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: ListTile(
        selected: selected,
        // contentPadding: , 16 horizontal by default
        onTap: onTap,
        minVerticalPadding: 16,
        horizontalTitleGap: titleGap,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: isActive
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onBackground),
            ),
            if (additionalInfo != null)
              Text(
                additionalInfo!,
                overflow: TextOverflow.ellipsis,
                style: isActive
                    ? theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onBackground)
                    : theme.textTheme.titleSmall,
              )
          ],
        ),
        trailing: onTap != null
            ? Icon(
                Icons.chevron_right_rounded,
                color: theme.indicatorColor,
              )
            : trailing,
      ),
    );
  }
}

class ListTileIcon extends StatelessWidget {
  const ListTileIcon({
    super.key,
    this.backgroundColor,
    this.assetPath,
    this.icon,
    this.color,
    this.size = 32,
  }) : assert((assetPath != null) ^ (icon != null), 'Only one between asset path and an icon has to be provided');
  static const iconSize = 32.0;
  final Color? backgroundColor;
  final Color? color;
  final String? assetPath;
  final IconData? icon;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }
}
