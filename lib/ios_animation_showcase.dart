import 'package:flutter/material.dart';
import 'package:your_finance_flutter/core/animations/ios_animation_manager.dart';
import 'package:your_finance_flutter/core/widgets/app_animations.dart';

/// iOS动效展示应用
/// 演示所有70+种动效组件
class IOSAnimationShowcase extends StatefulWidget {
  const IOSAnimationShowcase({super.key});

  @override
  State<IOSAnimationShowcase> createState() => _IOSAnimationShowcaseState();
}

class _IOSAnimationShowcaseState extends State<IOSAnimationShowcase>
    with TickerProviderStateMixin {
  final IOSAnimationManager _animationManager = IOSAnimationManager();

  // 演示状态
  bool _isLoading = false;
  bool _showSuccess = false;
  bool _showError = false;
  bool _showWarning = false;
  double _numberValue = 1234.56;
  double _progress = 0.0;
  int _counter = 0;
  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    // 启动一个简单的进度动画
    _startProgressAnimation();
  }

  void _startProgressAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _progress = (_progress + 0.1) % 1.0;
        });
        _startProgressAnimation();
      }
    });
  }

  @override
  void dispose() {
    _animationManager.dispose();
    super.dispose();
  }

  void _resetDemo() {
    setState(() {
      _isLoading = false;
      _showSuccess = false;
      _showError = false;
      _showWarning = false;
      _numberValue = 1234.56;
      _progress = 0.0;
      _counter = 0;
      _isDragging = false;
      _dragOffset = Offset.zero;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAnimationDialog(String title, Widget animationWidget) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 300,
          height: 200,
          child: Center(child: animationWidget),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _navigateWithAnimation(String animationType) {
    Widget demoPage = Scaffold(
      appBar: AppBar(
        title: Text('$animationType转场演示'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.animation,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              '$animationType转场效果演示页面',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '点击返回按钮体验转场动画',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

    PageRoute route;
    switch (animationType) {
      case 'slide':
        route = AppAnimations.createSlideRoute(demoPage);
        break;
      case 'fade':
        route = AppAnimations.createFadeRoute(demoPage);
        break;
      case 'scale':
        route = AppAnimations.createScaleRoute(demoPage);
        break;
      case 'rotation':
        route = AppAnimations.createRotationRoute(demoPage);
        break;
      case 'bottomSlide':
        route = AppAnimations.createBottomSlideRoute(demoPage);
        break;
      default:
        route = MaterialPageRoute(builder: (_) => demoPage);
    }

    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('iOS动效展示'),
          backgroundColor: Colors.blue,
          actions: [
            _animationManager.animatedButton(
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.refresh),
              ),
              onPressed: _resetDemo,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 统计信息
              _buildStatsCard(),
              const SizedBox(height: 24),

              // 数据显示动画
              _buildDataDisplaySection(),
              const SizedBox(height: 32),

              // 状态过渡动画
              _buildStateTransitionSection(),
              const SizedBox(height: 32),

              // 进度指示器动画
              _buildProgressSection(),
              const SizedBox(height: 32),

              // 列表和表格动画
              _buildListTableSection(),
              const SizedBox(height: 32),

              // 图表可视化动画
              _buildChartSection(),
              const SizedBox(height: 32),

              // 导航和转场动画
              _buildNavigationSection(),
              const SizedBox(height: 32),

              // 按钮和交互动画
              _buildInteractionSection(),
              const SizedBox(height: 32),

              // 特效动画
              _buildSpecialEffectsSection(),
              const SizedBox(height: 32),

              // 金融特定动画
              _buildFinancialSection(),
              const SizedBox(height: 32),

              // 控制面板
              _buildControlPanel(),
              const SizedBox(height: 32),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showSnackBar('浮动按钮点击'),
          child: const Icon(Icons.add),
        ),
      );

  Widget _buildSection({required String title, required Widget child}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      );

  Widget _buildStatsCard() => Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('72', '动画数量'),
              _buildStatItem('10', '动画类别'),
              _buildStatItem('实时', '演示状态'),
            ],
          ),
        ),
      );

  Widget _buildStatItem(String value, String label) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      );

  Widget _buildDataDisplaySection() => _buildSection(
        title: '📊 数据显示动画 (5种)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInteractiveButton(
                  '整数计数器',
                  () => _showAnimationDialog(
                    '整数计数器',
                    AppAnimations.animatedIntegerCounter(value: _counter),
                  ),
                ),
                _buildInteractiveButton(
                  '百分比显示',
                  () => _showAnimationDialog(
                    '百分比显示',
                    AppAnimations.animatedPercentage(
                      percentage: _progress * 100,
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '货币金额',
                  () => _showAnimationDialog(
                    '货币金额',
                    AppAnimations.animatedCurrencyAmount(
                      amount: _numberValue,
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '跳动计数器',
                  () => _showAnimationDialog(
                    '跳动计数器',
                    AppAnimations.animatedBouncingCounter(
                      value: _counter,
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '渐变数字',
                  () => _showAnimationDialog(
                    '渐变数字',
                    AppAnimations.animatedGradientNumber(
                      value: _numberValue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInteractiveButton('增加计数器', () => setState(() => _counter++)),
          ],
        ),
      );

  Widget _buildStateTransitionSection() => _buildSection(
        title: '🔄 状态过渡动画 (7种)',
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildInteractiveButton(
              '加载指示器',
              () => _showAnimationDialog(
                '加载指示器',
                AppAnimations.animatedLoadingIndicator(
                  size: 40,
                  message: _isLoading ? '加载中...' : null,
                ),
              ),
            ),
            _buildInteractiveButton(
              '成功反馈',
              () => _showAnimationDialog(
                '成功反馈',
                AppAnimations.animatedSuccessFeedback(
                  showSuccess: true,
                  child: _buildDemoCard('成功', Icons.check),
                ),
              ),
            ),
            _buildInteractiveButton(
              '错误反馈',
              () => _showAnimationDialog(
                '错误反馈',
                AppAnimations.animatedErrorFeedback(
                  showError: true,
                  child: _buildDemoCard('错误', Icons.error),
                ),
              ),
            ),
            _buildInteractiveButton(
              '等待状态',
              () => _showAnimationDialog(
                '等待状态',
                AppAnimations.animatedWaitingState(
                  isWaiting: true,
                  child: _buildDemoCard('等待', Icons.hourglass_empty),
                ),
              ),
            ),
            _buildInteractiveButton(
              '状态切换',
              () => _showAnimationDialog(
                '状态切换',
                AppAnimations.animatedStateTransition(
                  status: StatusType.success,
                  child: _buildDemoCard('状态', Icons.sync),
                ),
              ),
            ),
            _buildInteractiveButton(
              '步骤完成',
              () => _showAnimationDialog(
                '步骤完成',
                AppAnimations.animatedStepCompletion(
                  isCompleted: true,
                  child: _buildDemoCard('完成', Icons.done),
                ),
              ),
            ),
            _buildInteractiveButton(
              '验证状态',
              () => _showAnimationDialog(
                '验证状态',
                AppAnimations.animatedValidationState(
                  state: ValidationState.valid,
                  child: _buildDemoCard('验证', Icons.verified),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildProgressSection() => _buildSection(
        title: '📈 进度指示器动画 (9种)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInteractiveButton(
                  '进度指示器',
                  () => _showAnimationDialog(
                    '进度指示器',
                    AppAnimations.animatedProgressIndicator(
                      progress: _progress,
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '圆环进度',
                  () => _showAnimationDialog(
                    '圆环进度',
                    AppAnimations.animatedCircularProgress(
                      progress: _progress,
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '线性进度',
                  () => _showAnimationDialog(
                    '线性进度',
                    AppAnimations.animatedLinearProgress(
                      progress: _progress,
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '步骤计数器',
                  () => _showAnimationDialog(
                    '步骤计数器',
                    AppAnimations.animatedStepCounter(
                      currentStep: (_progress * 5).toInt(),
                      totalSteps: 5,
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '百分比环',
                  () => _showAnimationDialog(
                    '百分比环',
                    AppAnimations.animatedPercentageRing(
                      percentage: _progress * 100,
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '加载进度',
                  () => _showAnimationDialog(
                    '加载进度',
                    AppAnimations.animatedLoadingProgress(
                      progress: _progress,
                      loadingText: '下载中...',
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '完成指示器',
                  () => _showAnimationDialog(
                    '完成指示器',
                    AppAnimations.animatedCompletionIndicator(
                      isCompleted: true,
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '计时器进度',
                  () => _showAnimationDialog(
                    '计时器进度',
                    AppAnimations.animatedTimerProgress(
                      totalTime: const Duration(seconds: 10),
                      remainingTime: const Duration(seconds: 7),
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '下载进度',
                  () => _showAnimationDialog(
                    '下载进度',
                    AppAnimations.animatedDownloadProgress(
                      progress: _progress,
                      fileName: 'demo.pdf',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInteractiveButton(
              '调整进度',
              () => setState(() => _progress = (_progress + 0.2) % 1.0),
            ),
          ],
        ),
      );

  Widget _buildListTableSection() => _buildSection(
        title: '📋 列表和表格动画 (6种)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInteractiveButton(
                  '列表插入',
                  () => _showAnimationDialog(
                    '列表插入动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAnimations.animatedListSlideInsert(
                          child: _buildDemoCard('新插入项', Icons.add),
                        ),
                        const SizedBox(height: 8),
                        Text('从左侧滑入并淡入效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '列表组合',
                  () => _showAnimationDialog(
                    '列表组合动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAnimations.animatedListCombined(
                          index: 1,
                          child: _buildDemoCard('组合动画', Icons.layers),
                        ),
                        const SizedBox(height: 8),
                        Text('从右侧滑入+缩放+淡入效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '列表排序',
                  () => _showAnimationDialog(
                    '列表排序动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAnimations.animatedListSort(
                          oldIndex: 0,
                          newIndex: 1,
                          child: _buildDemoCard('排序中', Icons.sort),
                        ),
                        const SizedBox(height: 8),
                        Text('位置交换时的滑动效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '表格展开',
                  () => _showAnimationDialog(
                    '表格展开动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAnimations.animatedTableRowExpand(
                          isExpanded: true,
                          child: _buildDemoCard('可展开行', Icons.expand_more),
                        ),
                        const SizedBox(height: 8),
                        Text('行展开时的伸缩动画', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '列排序',
                  () => _showAnimationDialog(
                    '列排序动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAnimations.animatedTableColumnSort(
                          isSorting: true,
                          child: _buildDemoCard('排序列', Icons.view_column),
                        ),
                        const SizedBox(height: 8),
                        Text('列排序时的闪烁效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '列表拖拽',
                  () => _showAnimationDialog(
                    '列表拖拽动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAnimations.animatedListDrag(
                          isDragging: true,
                          dragOffset: const Offset(20, 0),
                          child: _buildDemoCard('正在拖拽', Icons.drag_handle),
                        ),
                        const SizedBox(height: 8),
                        Text('拖拽时的位移和阴影效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInteractiveButton(
                  '切换成功',
                  () => setState(() => _showSuccess = !_showSuccess),
                ),
                const SizedBox(width: 16),
                _buildInteractiveButton(
                  '切换拖拽',
                  () => setState(() {
                    _isDragging = !_isDragging;
                    _dragOffset =
                        _isDragging ? const Offset(20, 0) : Offset.zero;
                  }),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildChartSection() => _buildSection(
        title: '📈 图表可视化动画 (5种)',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInteractiveButton(
                  '柱状图',
                  () => _showAnimationDialog(
                    '柱状图动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 180,
                          child: AppAnimations.animatedBarChart(
                            values: [30, 60, 90, 45, 75],
                            maxValue: 100,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('柱子依次弹跳增长效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '线图',
                  () => _showAnimationDialog(
                    '线图动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 180,
                          child: AppAnimations.animatedLineChart(
                            values: [20, 40, 80, 60, 90],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('线条从左到右绘制效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '饼图',
                  () => _showAnimationDialog(
                    '饼图动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: AppAnimations.animatedPieChart(
                            values: [30, 25, 20, 15, 10],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('扇形依次填充效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '数据点',
                  () => _showAnimationDialog(
                    '数据点动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppAnimations.animatedDataPoint(
                          isHighlighted: true,
                          child: _buildDemoCard('高亮数据点', Icons.scatter_plot),
                        ),
                        const SizedBox(height: 8),
                        Text('数据点缩放和颜色变化', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                _buildInteractiveButton(
                  '网格',
                  () => _showAnimationDialog(
                    '网格动画演示',
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 180,
                          child: AppAnimations.animatedChartGrid(
                            horizontalLines: 4,
                            verticalLines: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('网格线依次绘制效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildNavigationSection() => _buildSection(
        title: '🧭 导航和转场动画 (8种)',
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildInteractiveButton('滑动转场', () => _navigateWithAnimation('slide')),
            _buildInteractiveButton('渐变转场', () => _navigateWithAnimation('fade')),
            _buildInteractiveButton('缩放转场', () => _navigateWithAnimation('scale')),
            _buildInteractiveButton('旋转转场', () => _navigateWithAnimation('rotation')),
            _buildInteractiveButton('底部滑入', () => _navigateWithAnimation('bottomSlide')),
            _buildInteractiveButton(
              '标签切换',
              () => _showAnimationDialog(
                '标签切换',
                AppAnimations.animatedTabSwitcher(
                  currentIndex: 0,
                  tabs: [
                    _buildDemoCard('Tab1', Icons.tab),
                    _buildDemoCard('Tab2', Icons.tab),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '抽屉过渡',
              () => _showAnimationDialog(
                '抽屉过渡',
                AppAnimations.animatedDrawerTransition(
                  isOpen: _showSuccess,
                  position: DrawerPosition.right,
                  child: _buildDemoCard('抽屉', Icons.menu),
                ),
              ),
            ),
            _buildInteractiveButton(
              '底部导航',
              () => _showAnimationDialog(
                '底部导航',
                AppAnimations.animatedBottomNavigation(
                  currentIndex: 0,
                  items: [
                    _buildDemoCard('首页', Icons.home),
                    _buildDemoCard('设置', Icons.settings),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildInteractionSection() => _buildSection(
        title: '👆 按钮和交互动画 (8种)',
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildInteractiveButton(
              '触摸反馈',
              () => _showAnimationDialog(
                '触摸反馈动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedTouchFeedback(
                      child: _buildDemoCard('点击我', Icons.touch_app),
                      onPressed: () => _showSnackBar('触摸反馈触发'),
                    ),
                    const SizedBox(height: 8),
                    Text('点击按钮查看缩放反馈效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '长按反馈',
              () => _showAnimationDialog(
                '长按反馈动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedLongPress(
                      child: _buildDemoCard('长按我', Icons.touch_app),
                      onLongPress: () => _showSnackBar('长按反馈触发'),
                    ),
                    const SizedBox(height: 8),
                    Text('长按按钮查看持续反馈效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '悬停效果',
              () => _showAnimationDialog(
                '悬停效果动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedHover(
                      child: _buildDemoCard('悬停测试', Icons.mouse),
                      hoverScale: 1.1,
                    ),
                    const SizedBox(height: 8),
                    Text('鼠标悬停查看缩放效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '摇晃效果',
              () => _showAnimationDialog(
                '摇晃效果动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedShake(
                      child: _buildDemoCard('摇晃测试', Icons.vibration),
                      shouldShake: true,
                    ),
                    const SizedBox(height: 8),
                    Text('查看左右摇晃动画效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '滚动列表',
              () => _showAnimationDialog(
                '滚动列表动画演示',
                SizedBox(
                  height: 200,
                  child: AppAnimations.animatedScrollList(
                    children: [
                      _buildDemoCard('项目1', Icons.list),
                      _buildDemoCard('项目2', Icons.list),
                      _buildDemoCard('项目3', Icons.list),
                      _buildDemoCard('项目4', Icons.list),
                      _buildDemoCard('项目5', Icons.list),
                    ],
                  ),
                ),
              ),
            ),
            _buildInteractiveButton(
              '拖拽反馈',
              () => _showAnimationDialog(
                '拖拽反馈动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedDragFeedback(
                      child: _buildDemoCard('拖拽测试', Icons.drag_indicator),
                      dragOffset: const Offset(30, 10),
                      isDragging: true,
                    ),
                    const SizedBox(height: 8),
                    Text('查看拖拽时的阴影和位移效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildSpecialEffectsSection() => _buildSection(
        title: '✨ 特效动画 (6种)',
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildInteractiveButton(
              '粒子效果',
              () => _showAnimationDialog(
                '粒子效果动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedParticles(
                      child: _buildDemoCard('粒子发射', Icons.blur_on),
                      particleCount: 20,
                    ),
                    const SizedBox(height: 8),
                    Text('粒子从中心向四周发射扩散', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '波纹效果',
              () => _showAnimationDialog(
                '波纹效果动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedRipple(
                      child: _buildDemoCard('水波涟漪', Icons.waves),
                      maxRadius: 80,
                    ),
                    const SizedBox(height: 8),
                    Text('水波纹从中心向外扩散', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '发光效果',
              () => _showAnimationDialog(
                '发光效果动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedGlow(
                      child: _buildDemoCard('光芒四射', Icons.lightbulb),
                    ),
                    const SizedBox(height: 8),
                    Text('呼吸式的光晕发光效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '爆炸效果',
              () => _showAnimationDialog(
                '爆炸效果动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedExplosion(
                      child: _buildDemoCard('爆炸特效', Icons.burst_mode),
                      shouldExplode: true,
                    ),
                    const SizedBox(height: 8),
                    Text('元素破碎飞散的爆炸效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '脉冲波',
              () => _showAnimationDialog(
                '脉冲波动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedPulseWave(
                      child: _buildDemoCard('脉冲发射', Icons.wifi_tethering),
                      maxRadius: 60,
                    ),
                    const SizedBox(height: 8),
                    Text('圆形脉冲波向外扩散', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '扭曲效果',
              () => _showAnimationDialog(
                '扭曲效果动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedDistortion(
                      child: _buildDemoCard('扭曲变形', Icons.blur_circular),
                      distortionFactor: 0.2,
                    ),
                    const SizedBox(height: 8),
                    Text('元素形状的扭曲变形效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFinancialSection() => _buildSection(
        title: '💰 金融特定动画 (6种)',
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildInteractiveButton(
              '钱包抖动',
              () => _showAnimationDialog(
                '钱包抖动动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedWalletShake(
                      child: _buildDemoCard('钱包抖动', Icons.account_balance_wallet),
                      shouldShake: true,
                    ),
                    const SizedBox(height: 8),
                    Text('余额不足时的抖动提醒', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '收入飘浮',
              () => _showAnimationDialog(
                '收入飘浮动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedIncomeFloat(
                      amount: '¥2,500.00',
                      shouldFloat: true,
                    ),
                    const SizedBox(height: 8),
                    Text('收入到账时的飘浮提示', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '支出波纹',
              () => _showAnimationDialog(
                '支出波纹动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedExpenseRipple(
                      amount: '¥850.00',
                      shouldRipple: true,
                    ),
                    const SizedBox(height: 8),
                    Text('支出时的水波纹扩散效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '预算警戒',
              () => _showAnimationDialog(
                '预算警戒动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedBudgetAlert(
                      child: _buildDemoCard('预算超支', Icons.warning),
                      isAlerting: true,
                    ),
                    const SizedBox(height: 8),
                    Text('预算接近上限时的闪烁提醒', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '投资波动',
              () => _showAnimationDialog(
                '投资波动动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 100,
                      child: AppAnimations.animatedInvestmentWave(
                        values: [100, 120, 95, 110, 130, 125, 140],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('投资收益的波动曲线动画', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _buildInteractiveButton(
              '信用卡消费',
              () => _showAnimationDialog(
                '信用卡消费动画演示',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppAnimations.animatedCreditCardSpend(
                      child: _buildDemoCard('消费成功', Icons.credit_card),
                      isSpending: true,
                      spendAmount: 299.99,
                    ),
                    const SizedBox(height: 8),
                    Text('信用卡消费时的动态效果', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildControlPanel() => _buildSection(
        title: '🎮 动画状态控制面板',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '控制以下动画的状态参数，点击对应按钮来切换状态：',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildControlButton(
                  label: _isLoading ? '🔄 加载中' : '⏸️ 停止加载',
                  color: _isLoading ? Colors.blue : Colors.grey,
                  onPressed: () => setState(() => _isLoading = !_isLoading),
                  description: '控制加载状态动画',
                ),
                _buildControlButton(
                  label: _showSuccess ? '✅ 成功显示' : '❌ 隐藏成功',
                  color: _showSuccess ? Colors.green : Colors.grey,
                  onPressed: () => setState(() => _showSuccess = !_showSuccess),
                  description: '控制成功状态动画',
                ),
                _buildControlButton(
                  label: _showError ? '🚨 错误显示' : '⚪ 隐藏错误',
                  color: _showError ? Colors.red : Colors.grey,
                  onPressed: () => setState(() => _showError = !_showError),
                  description: '控制错误状态动画',
                ),
                _buildControlButton(
                  label: _showWarning ? '⚠️ 警告显示' : '⚪ 隐藏警告',
                  color: _showWarning ? Colors.orange : Colors.grey,
                  onPressed: () => setState(() => _showWarning = !_showWarning),
                  description: '控制警告状态动画',
                ),
                _buildControlButton(
                  label: '💰 增加金额',
                  color: Colors.purple,
                  onPressed: () => setState(() => _numberValue += 123.45),
                  description: '增加数值以触发数字动画',
                ),
                _buildControlButton(
                  label: '🔄 重置演示',
                  color: Colors.teal,
                  onPressed: _resetDemo,
                  description: '重置所有动画状态',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 当前状态：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '加载状态: ${_isLoading ? "开启" : "关闭"}  |  '
                    '成功状态: ${_showSuccess ? "开启" : "关闭"}  |  '
                    '错误状态: ${_showError ? "开启" : "关闭"}  |  '
                    '警告状态: ${_showWarning ? "开启" : "关闭"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  Text(
                    '当前数值: ¥${_numberValue.toStringAsFixed(2)}  |  '
                    '计数器: $_counter',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildControlButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required String description,
  }) =>
      Tooltip(
        message: description,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      );

  Widget _buildInteractiveButton(String text, VoidCallback onPressed) =>
      ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      );

  Widget _buildDemoCard(String title, IconData icon) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
