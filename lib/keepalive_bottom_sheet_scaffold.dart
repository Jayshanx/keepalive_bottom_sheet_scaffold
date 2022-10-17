import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'bottom_sheet_suspended_curve.dart';

const Curve _decelerateEasing = Cubic(0.0, 0.0, 0.2, 1.0);
const Curve _modalBottomSheetCurve = _decelerateEasing;
const double _willPopThreshold = 0.8;
const double _minFlingVelocity = 500.0;
const double _closeProgressThreshold = 0.6;
const Radius _defaultBarTopRadius = Radius.circular(15);

class KeepAliveModalScrollController extends InheritedWidget {
  /// Creates a widget that associates a [ScrollController] with a subtree.
  KeepAliveModalScrollController({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(
          key: key,
          child: PrimaryScrollController(
            controller: controller,
            child: child,
          ),
        );

  /// The [ScrollController] associated with the subtree.
  ///
  /// See also:
  ///
  ///  * [ScrollView.controller], which discusses the purpose of specifying a
  ///    scroll controller.
  final ScrollController controller;

  /// Returns the [ScrollController] most closely associated with the given
  /// context.
  ///
  /// Returns null if there is no [ScrollController] associated with the given
  /// context.
  static ScrollController? of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<KeepAliveModalScrollController>();
    return result?.controller;
  }

  @override
  bool updateShouldNotify(KeepAliveModalScrollController oldWidget) => controller != oldWidget.controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ScrollController>('controller', controller, ifNull: 'no controller', showName: false));
  }
}

class KeepAliveBottomSheet extends InheritedWidget {
  final _KeepAliveBottomSheetScaffoldState state;

  final Radius? topRadius;

  const KeepAliveBottomSheet({
    Key? key,
    required super.child,
    required this.state,
    this.topRadius,
  }) : super(key: key);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  static _KeepAliveBottomSheetScaffoldState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<KeepAliveBottomSheet>()!.state;
  }
}

class KeepAliveBottomWidget {
  final Widget child;

  /// Indicate the duration when expand bottom sheet
  final Duration? duration;

  /// Function trigger when hide bottom sheet
  final Function()? onHide;

  /// lazy init bottomSheet default is true
  final bool lazy;

  final Radius topRadius;

  /// Allows the bottom sheet to  go beyond the top bound of the content,
  /// but then bounce the content back to the edge of
  /// the top bound.
  final bool bounce;

  // Force the widget to fill the maximum size of the viewport
  // or if false it will fit to the content of the widget
  final bool expand;

  /// If true, the bottom sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// Default is true.
  final bool enableDrag;

  KeepAliveBottomWidget({
    required this.child,
    this.duration,
    this.lazy = true,
    this.topRadius = _defaultBarTopRadius,
    this.expand = true,
    this.bounce = true,
    this.enableDrag = true,
    this.onHide,
  });
}

/// Class to generate the bottom bar sheet widget
class KeepAliveBottomSheetScaffold extends StatefulWidget {
  /// If true, and [bottomNavigationBar] or [persistentFooterButtons]
  /// is specified, then the [body] extends to the bottom of the Scaffold,
  /// instead of only extending to the top of the [bottomNavigationBar]
  /// or the [persistentFooterButtons].
  ///
  /// If true, a [MediaQuery] widget whose bottom padding matches the height
  /// of the [bottomNavigationBar] will be added above the scaffold's [body].
  ///
  /// This property is often useful when the [bottomNavigationBar] has
  /// a non-rectangular shape, like [CircularNotchedRectangle], which
  /// adds a [FloatingActionButton] sized notch to the top edge of the bar.
  /// In this case specifying `extendBody: true` ensures that scaffold's
  /// body will be visible through the bottom navigation bar's notch.
  ///
  /// See also:
  ///
  ///  * [extendBodyBehindAppBar], which extends the height of the body
  ///    to the top of the scaffold.
  final bool extendBody;

  /// If true, and an [appBar] is specified, then the height of the [body] is
  /// extended to include the height of the app bar and the top of the body
  /// is aligned with the top of the app bar.
  ///
  /// This is useful if the app bar's [AppBar.backgroundColor] is not
  /// completely opaque.
  ///
  /// This property is false by default. It must not be null.
  ///
  /// See also:
  ///
  ///  * [extendBody], which extends the height of the body to the bottom
  ///    of the scaffold.
  final bool extendBodyBehindAppBar;

  /// An app bar to display at the top of the scaffold.
  final PreferredSizeWidget? appBar;

  /// The primary content of the scaffold.
  ///
  /// Displayed below the [appBar], above the bottom of the ambient
  /// [MediaQuery]'s [MediaQueryData.viewInsets], and behind the
  /// [floatingActionButton] and [drawer]. If [resizeToAvoidBottomInset] is
  /// false then the body is not resized when the onscreen keyboard appears,
  /// i.e. it is not inset by `viewInsets.bottom`.
  ///
  /// The widget in the body of the scaffold is positioned at the top-left of
  /// the available space between the app bar and the bottom of the scaffold. To
  /// center this widget instead, consider putting it in a [Center] widget and
  /// having that be the body. To expand this widget instead, consider
  /// putting it in a [SizedBox.expand].
  ///
  /// If you have a column of widgets that should normally fit on the screen,
  /// but may overflow and would in such cases need to scroll, consider using a
  /// [ListView] as the body of the scaffold. This is also a good choice for
  /// the case where your body is a scrollable list.
  final Widget? body;

  /// A button displayed floating above [body], in the bottom right corner.
  ///
  /// Typically a [FloatingActionButton].
  final Widget? floatingActionButton;

  /// Responsible for determining where the [floatingActionButton] should go.
  ///
  /// If null, the [ScaffoldState] will use the default location, [FloatingActionButtonLocation.endFloat].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Animator to move the [floatingActionButton] to a new [floatingActionButtonLocation].
  ///
  /// If null, the [ScaffoldState] will use the default animator, [FloatingActionButtonAnimator.scaling].
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  /// A set of buttons that are displayed at the bottom of the scaffold.
  ///
  /// Typically this is a list of [TextButton] widgets. These buttons are
  /// persistently visible, even if the [body] of the scaffold scrolls.
  ///
  /// These widgets will be wrapped in an [OverflowBar].
  ///
  /// The [persistentFooterButtons] are rendered above the
  /// [bottomNavigationBar] but below the [body].
  final List<Widget>? persistentFooterButtons;

  /// A panel displayed to the side of the [body], often hidden on mobile
  /// devices. Swipes in from either left-to-right ([TextDirection.ltr]) or
  /// right-to-left ([TextDirection.rtl])
  ///
  /// Typically a [Drawer].
  ///
  /// To open the drawer, use the [ScaffoldState.openDrawer] function.
  ///
  /// To close the drawer, use either [ScaffoldState.closeDrawer] or
  /// [Navigator.pop].
  ///
  /// {@tool dartpad}
  /// To disable the drawer edge swipe, set the
  /// [Scaffold.drawerEnableOpenDragGesture] to false. Then, use
  /// [ScaffoldState.openDrawer] to open the drawer and [Navigator.pop] to close
  /// it.
  ///
  /// ** See code in examples/api/lib/material/scaffold/scaffold.drawer.0.dart **
  /// {@end-tool}
  final Widget? drawer;

  /// Optional callback that is called when the [Scaffold.drawer] is opened or closed.
  final DrawerCallback? onDrawerChanged;

  /// A panel displayed to the side of the [body], often hidden on mobile
  /// devices. Swipes in from right-to-left ([TextDirection.ltr]) or
  /// left-to-right ([TextDirection.rtl])
  ///
  /// Typically a [Drawer].
  ///
  /// To open the drawer, use the [ScaffoldState.openEndDrawer] function.
  ///
  /// To close the drawer, use either [ScaffoldState.closeEndDrawer] or
  /// [Navigator.pop].
  ///
  /// {@tool dartpad}
  /// To disable the drawer edge swipe, set the
  /// [Scaffold.endDrawerEnableOpenDragGesture] to false. Then, use
  /// [ScaffoldState.openEndDrawer] to open the drawer and [Navigator.pop] to
  /// close it.
  ///
  /// ** See code in examples/api/lib/material/scaffold/scaffold.end_drawer.0.dart **
  /// {@end-tool}
  final Widget? endDrawer;

  /// Optional callback that is called when the [Scaffold.endDrawer] is opened or closed.
  final DrawerCallback? onEndDrawerChanged;

  /// The color to use for the scrim that obscures primary content while a drawer is open.
  ///
  /// If this is null, then [DrawerThemeData.scrimColor] is used. If that
  /// is also null, then it defaults to [Colors.black54].
  final Color? drawerScrimColor;

  /// The color of the [Material] widget that underlies the entire Scaffold.
  ///
  /// The theme's [ThemeData.scaffoldBackgroundColor] by default.
  final Color? backgroundColor;

  /// A bottom navigation bar to display at the bottom of the scaffold.
  ///
  /// Snack bars slide from underneath the bottom navigation bar while bottom
  /// sheets are stacked on top.
  ///
  /// The [bottomNavigationBar] is rendered below the [persistentFooterButtons]
  /// and the [body].
  final Widget? bottomNavigationBar;

  /// The persistent bottom sheet to display.
  ///
  /// A persistent bottom sheet shows information that supplements the primary
  /// content of the app. A persistent bottom sheet remains visible even when
  /// the user interacts with other parts of the app.
  ///
  /// A closely related widget is a modal bottom sheet, which is an alternative
  /// to a menu or a dialog and prevents the user from interacting with the rest
  /// of the app. Modal bottom sheets can be created and displayed with the
  /// [showModalBottomSheet] function.
  ///
  /// Unlike the persistent bottom sheet displayed by [showBottomSheet]
  /// this bottom sheet is not a [LocalHistoryEntry] and cannot be dismissed
  /// with the scaffold appbar's back button.
  ///
  /// If a persistent bottom sheet created with [showBottomSheet] is already
  /// visible, it must be closed before building the Scaffold with a new
  /// [bottomSheet].
  ///
  /// The value of [bottomSheet] can be any widget at all. It's unlikely to
  /// actually be a [BottomSheet], which is used by the implementations of
  /// [showBottomSheet] and [showModalBottomSheet]. Typically it's a widget
  /// that includes [Material].
  ///
  /// See also:
  ///
  ///  * [showBottomSheet], which displays a bottom sheet as a route that can
  ///    be dismissed with the scaffold's back button.
  ///  * [showModalBottomSheet], which displays a modal bottom sheet.
  final Widget? bottomSheet;

  /// If true the [body] and the scaffold's floating widgets should size
  /// themselves to avoid the onscreen keyboard whose height is defined by the
  /// ambient [MediaQuery]'s [MediaQueryData.viewInsets] `bottom` property.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true.
  final bool? resizeToAvoidBottomInset;

  /// Whether this scaffold is being displayed at the top of the screen.
  ///
  /// If true then the height of the [appBar] will be extended by the height
  /// of the screen's status bar, i.e. the top padding for [MediaQuery].
  ///
  /// The default value of this property, like the default value of
  /// [AppBar.primary], is true.
  final bool primary;

  /// {@macro flutter.material.DrawerController.dragStartBehavior}
  final DragStartBehavior drawerDragStartBehavior;

  /// The width of the area within which a horizontal swipe will open the
  /// drawer.
  ///
  /// By default, the value used is 20.0 added to the padding edge of
  /// `MediaQuery.of(context).padding` that corresponds to the surrounding
  /// [TextDirection]. This ensures that the drag area for notched devices is
  /// not obscured. For example, if `TextDirection.of(context)` is set to
  /// [TextDirection.ltr], 20.0 will be added to
  /// `MediaQuery.of(context).padding.left`.
  final double? drawerEdgeDragWidth;

  /// Determines if the [Scaffold.drawer] can be opened with a drag
  /// gesture.
  ///
  /// By default, the drag gesture is enabled.
  final bool drawerEnableOpenDragGesture;

  /// Determines if the [Scaffold.endDrawer] can be opened with a
  /// drag gesture.
  ///
  /// By default, the drag gesture is enabled.
  final bool endDrawerEnableOpenDragGesture;

  /// Restoration ID to save and restore the state of the [Scaffold].
  ///
  /// If it is non-null, the scaffold will persist and restore whether the
  /// [drawer] and [endDrawer] was open or closed.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  ///bottom sheet widget want to keeAlive when hide
  final KeepAliveBottomWidget? keepAliveBottomSheet;

  const KeepAliveBottomSheetScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.onDrawerChanged,
    this.endDrawer,
    this.onEndDrawerChanged,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.keepAliveBottomSheet,
  }) : super(key: key);

  @override
  _KeepAliveBottomSheetScaffoldState createState() => _KeepAliveBottomSheetScaffoldState();
}

class _KeepAliveBottomSheetScaffoldState extends State<KeepAliveBottomSheetScaffold> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late final _lazyInitialController = ValueNotifier<bool>(widget.keepAliveBottomSheet?.lazy ?? true);

  ScrollController? _scrollController;

  void show() {
    _lazyInitialController.value = false;
    controller.forward();
  }

  void hide() {
    controller.reverse();
  }

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: widget.keepAliveBottomSheet?.duration ?? const Duration(milliseconds: 300));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = Scaffold(
      key: widget.key,
      appBar: widget.appBar,
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
      persistentFooterButtons: widget.persistentFooterButtons,
      drawer: widget.drawer,
      onDrawerChanged: widget.onDrawerChanged,
      endDrawer: widget.endDrawer,
      onEndDrawerChanged: widget.onEndDrawerChanged,
      bottomNavigationBar: widget.bottomNavigationBar,
      bottomSheet: widget.bottomSheet,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      primary: widget.primary,
      drawerDragStartBehavior: widget.drawerDragStartBehavior,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      drawerScrimColor: widget.drawerScrimColor,
      drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      restorationId: widget.restorationId,
    );

    final scrollController = PrimaryScrollController.of(context) ?? (_scrollController ??= ScrollController());
    return KeepAliveBottomSheet(
      state: this,
      child: KeepAliveModalScrollController(
        controller: scrollController,
        child: Builder(builder: (context) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              scaffold,
              ValueListenableBuilder<bool>(
                valueListenable: _lazyInitialController,
                builder: (context, lazyInit, child) {
                  if (lazyInit || widget.keepAliveBottomSheet == null) {
                    return const SizedBox.shrink();
                  }

                  var keepAliveBottomWidget = widget.keepAliveBottomSheet!;
                  return KeepAliveModalBottomSheet(
                    scrollController: scrollController,
                    animationController: controller,
                    topRadius: keepAliveBottomWidget.topRadius,
                    enableDrag: keepAliveBottomWidget.enableDrag,
                    onHide: keepAliveBottomWidget.onHide,
                    expanded: keepAliveBottomWidget.expand,
                    bounce: keepAliveBottomWidget.bounce,
                    child: keepAliveBottomWidget.child,
                  );
                },
              )
            ],
          );
        }),
      ),
    );
  }
}

///
/// Most reference the package modal_bottom_sheet
/// https://pub.flutter-io.cn/packages/modal_bottom_sheet
/// https://github.com/jamesblasco/modal_bottom_sheet/blob/main/modal_bottom_sheet/lib/src/bottom_sheet.dart
///
class KeepAliveModalBottomSheet extends StatefulWidget {
  /// The animation controller that controls the bottom sheet's entrance and
  /// exit animations.
  ///
  /// The BottomSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController animationController;

  final ScrollController scrollController;

  /// A builder for the contents of the sheet.
  ///
  final Widget child;

  /// The curve used by the animation showing and dismissing the bottom sheet.
  ///
  /// If no curve is provided it falls back to `decelerateEasing`.
  final Curve? animationCurve;

  /// If true, the bottom sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// Default is true.
  final bool enableDrag;

  /// Called when the bottom sheet onHide
  final Function()? onHide;

  /// Allows the bottom sheet to  go beyond the top bound of the content,
  /// but then bounce the content back to the edge of
  /// the top bound.
  final bool bounce;

  // Force the widget to fill the maximum size of the viewport
  // or if false it will fit to the content of the widget
  final bool expanded;

  final Radius topRadius;

  const KeepAliveModalBottomSheet({
    Key? key,
    required this.scrollController,
    required this.animationController,
    required this.expanded,
    required this.child,
    this.enableDrag = true,
    this.bounce = true,
    this.animationCurve,
    this.onHide,
    this.topRadius = _defaultBarTopRadius,
  }) : super(key: key);

  @override
  State<KeepAliveModalBottomSheet> createState() => _KeepAliveModalBottomSheetState();
}

class _KeepAliveModalBottomSheetState extends State<KeepAliveModalBottomSheet> with TickerProviderStateMixin {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'BottomSheet child');

  ScrollController get _scrollController => widget.scrollController;

  AnimationController get _animationController => widget.animationController;

  late AnimationController _bounceDragController;

  double? get _childHeight {
    final childContext = _childKey.currentContext;
    final renderBox = childContext?.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  bool get _dismissUnderway => _animationController.status == AnimationStatus.reverse;

  // Detect if user is dragging.
  // Used on NotificationListener to detect if ScrollNotifications are
  // before or after the user stop dragging
  bool isDragging = false;

  bool get hasReachedWillPopThreshold => _animationController.value < _willPopThreshold;

  // bool get hasReachedCloseThreshold =>
  //     _animationController.value <
  //         (widget.closeProgressThreshold ?? _closeProgressThreshold);

  bool get hasReachedCloseThreshold => _animationController.value < _closeProgressThreshold;

  void _close() {
    isDragging = false;
    _animationController.reverse().then((value) {
      widget.onHide?.call();
    });
  }

  void _cancelClose() {
    _animationController.forward().then((value) {
      // When using WillPop, animation doesn't end at 1.
      // Check more in detail the problem
      if (!_animationController.isCompleted) {
        _animationController.value = 1;
      }
    });
    _bounceDragController.reverse();
  }

  bool _isCheckingShouldClose = false;

  FutureOr<bool> shouldClose() async {
    if (_isCheckingShouldClose) return false;
    // if (widget.shouldClose == null) return false;
    _isCheckingShouldClose = true;
    // final result = await widget.shouldClose?.call();
    // _isCheckingShouldClose = false;
    return false;
  }

  ParametricCurve<double> animationCurve = Curves.linear;

  void _handleDragUpdate(double primaryDelta) async {
    animationCurve = Curves.linear;
    assert(widget.enableDrag, 'Dragging is disabled');

    if (_dismissUnderway) return;
    isDragging = true;

    final progress = primaryDelta / (_childHeight ?? primaryDelta);

    if (hasReachedWillPopThreshold) {
      _cancelClose();
      final canClose = await shouldClose();
      if (canClose) {
        _close();
        return;
      } else {
        _cancelClose();
      }
    }

    // Bounce top
    final bounce = widget.bounce == true;
    final shouldBounce = _bounceDragController.value > 0;
    final isBouncing = (_animationController.value - progress) > 1;
    if (bounce && (shouldBounce || isBouncing)) {
      _bounceDragController.value -= progress * 10;
      return;
    }

    _animationController.value -= progress;
  }

  void _handleDragEnd(double velocity) async {
    assert(widget.enableDrag, 'Dragging is disabled');

    animationCurve = BottomSheetSuspendedCurve(
      _animationController.value,
      curve: _defaultCurve,
    );

    if (_dismissUnderway || !isDragging) return;
    isDragging = false;
    // ignore: unawaited_futures
    _bounceDragController.reverse();

    // If speed is bigger than _minFlingVelocity try to close it
    if (velocity > _minFlingVelocity) {
      _close();
    } else if (hasReachedCloseThreshold) {
      if (_animationController.value > 0.0) {
        // ignore: unawaited_futures
        _animationController.fling(velocity: -1.0);
      }
      _close();
    } else {
      _cancelClose();
    }
  }

  // As we cannot access the dragGesture detector of the scroll view
  // we can not know the DragDownDetails and therefore the end velocity.
  // VelocityTracker it is used to calculate the end velocity  of the scroll
  // when user is trying to close the modal by dragging
  VelocityTracker? _velocityTracker;
  DateTime? _startTime;

  void _handleScrollUpdate(ScrollNotification notification) {
    assert(notification.context != null);
    //Check if scrollController is used
    if (!_scrollController.hasClients) return;
    //Check if there is more than 1 attached ScrollController e.g. swiping page in PageView
    // ignore: invalid_use_of_protected_member
    if (_scrollController.positions.length > 1) return;

    if (_scrollController != Scrollable.of(notification.context!)!.widget.controller) return;

    final scrollPosition = _scrollController.position;

    if (scrollPosition.axis == Axis.horizontal) return;

    final isScrollReversed = scrollPosition.axisDirection == AxisDirection.down;
    final offset = isScrollReversed ? scrollPosition.pixels : scrollPosition.maxScrollExtent - scrollPosition.pixels;

    if (offset <= 0) {
      // Clamping Scroll Physics end with a ScrollEndNotification with a DragEndDetail class
      // while Bouncing Scroll Physics or other physics that Overflow don't return a drag end info

      // We use the velocity from DragEndDetail in case it is available
      if (notification is ScrollEndNotification) {
        final dragDetails = notification.dragDetails;
        if (dragDetails != null) {
          _handleDragEnd(dragDetails.primaryVelocity ?? 0);
          _velocityTracker = null;
          _startTime = null;
          return;
        }
      }

      // Otherwise the calculate the velocity with a VelocityTracker
      if (_velocityTracker == null) {
        final pointerKind = defaultPointerDeviceKind(context);
        _velocityTracker = VelocityTracker.withKind(pointerKind);
        _startTime = DateTime.now();
      }

      DragUpdateDetails? dragDetails;
      if (notification is ScrollUpdateNotification) {
        dragDetails = notification.dragDetails;
      }
      if (notification is OverscrollNotification) {
        dragDetails = notification.dragDetails;
      }
      assert(_velocityTracker != null);
      assert(_startTime != null);
      final startTime = _startTime!;
      final velocityTracker = _velocityTracker!;
      if (dragDetails != null) {
        final duration = startTime.difference(DateTime.now());
        velocityTracker.addPosition(duration, Offset(0, offset));
        _handleDragUpdate(dragDetails.delta.dy);
      } else if (isDragging) {
        final velocity = velocityTracker.getVelocity().pixelsPerSecond.dy;
        _velocityTracker = null;
        _startTime = null;
        _handleDragEnd(velocity);
      }
    }
  }

  Curve get _defaultCurve => widget.animationCurve ?? _modalBottomSheetCurve;

  late Animation<double> _barrierColorAnimation;

  Future<bool> _onPop() async {
    if (_animationController.value > 0.0) {
      _close();
      return false;
    }

    return true;
  }

  @override
  void initState() {
    animationCurve = _defaultCurve;
    _bounceDragController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _barrierColorAnimation = Tween<double>(begin: 0.0, end: .35).animate(_animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bounceAnimation = CurvedAnimation(
      parent: _bounceDragController,
      curve: Curves.easeOutCirc,
    );

    final mediaQuery = MediaQuery.of(context);

    var child = AnimatedBuilder(
      animation: _animationController,
      builder: (context, Widget? child) {
        assert(child != null);
        final animationValue = animationCurve.transform(mediaQuery.accessibleNavigation ? 1.0 : _animationController.value);
        final draggableChild = !widget.enableDrag
            ? child
            : KeyedSubtree(
                key: _childKey,
                child: AnimatedBuilder(
                  animation: bounceAnimation,
                  builder: (context, _) => CustomSingleChildLayout(
                    delegate: _CustomBottomSheetLayout(bounceAnimation.value),
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        _handleDragUpdate(details.delta.dy);
                      },
                      onVerticalDragEnd: (details) {
                        _handleDragEnd(details.primaryVelocity ?? 0);
                      },
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          _handleScrollUpdate(notification);
                          return false;
                        },
                        child: child!,
                      ),
                    ),
                  ),
                ),
              );
        return ClipRect(
          child: CustomSingleChildLayout(
            delegate: _ModalBottomSheetLayout(
              animationValue,
              false,
            ),
            child: draggableChild,
          ),
        );
      },
      child: RepaintBoundary(
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: widget.topRadius,
              topRight: widget.topRadius,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          elevation: 2,
          child: widget.child,
        ),
      ),
    );

    return WillPopScope(
      onWillPop: _onPop,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBarrier(),
          child,
        ],
      ),
    );
  }

  Widget _buildBarrier() {
    return AnimatedBuilder(
      animation: _barrierColorAnimation,
      builder: (context, _) {
        if (_barrierColorAnimation.value == 0.0) {
          return const SizedBox.shrink();
        }
        return GestureDetector(onTap: _close, child: Container(color: Colors.black.withOpacity(_barrierColorAnimation.value)));
      },
    );
  }
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  _ModalBottomSheetLayout(this.progress, this.expand);

  final double progress;
  final bool expand;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: expand ? constraints.maxHeight : 0,
      maxHeight: expand ? constraints.maxHeight : constraints.minHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _CustomBottomSheetLayout extends SingleChildLayoutDelegate {
  _CustomBottomSheetLayout(this.progress);

  final double progress;
  double? childHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight + progress * 8,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    childHeight ??= childSize.height;
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_CustomBottomSheetLayout oldDelegate) {
    if (progress != oldDelegate.progress) {
      childHeight = oldDelegate.childHeight;
      return true;
    }
    return false;
  }
}

// Checks the device input type as per the OS installed in it
// Mobile platforms will be default to `touch` while desktop will do to `mouse`
// Used with VelocityTracker
// https://github.com/flutter/flutter/pull/64267#issuecomment-694196304
PointerDeviceKind defaultPointerDeviceKind(BuildContext context) {
  final platform = Theme.of(context).platform; // ?? defaultTargetPlatform;
  switch (platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.android:
      return PointerDeviceKind.touch;
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return PointerDeviceKind.mouse;
    case TargetPlatform.fuchsia:
      return PointerDeviceKind.unknown;
  }
}
