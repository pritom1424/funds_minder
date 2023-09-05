import 'package:flutter/material.dart';
import 'package:funds_minder/View_Model/goals.dart';
import 'package:funds_minder/Widget/GoalSettings/new_goal.dart';
import 'package:funds_minder/Widget/GoalSettings/single_goal_item.dart';
import 'package:provider/provider.dart';

class GoalSettingsScreen extends StatefulWidget {
  static String goalScreenRoute = '/goal_screen';
  const GoalSettingsScreen({super.key});

  @override
  State<GoalSettingsScreen> createState() => _GoalSettingsScreenState();
}

class _GoalSettingsScreenState extends State<GoalSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> opacityAnimation;
  void showNewPop(BuildContext ct, Widget widg) {
    showModalBottomSheet(
        transitionAnimationController: _animationController,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        useSafeArea: true,
        isScrollControlled: true,
        context: ct,
        builder: (ctx) => widg);
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    opacityAnimation = CurvedAnimation(
        parent: Tween<double>(begin: 1, end: 0).animate(_animationController),
        curve: Curves.linear);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funds Minder'),
        actions: [
          TextButton.icon(
              onPressed: () {
                showNewPop(context, const NewGoal());
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: const Text('New Goal',
                  style: TextStyle(
                    color: Colors.white,
                  )))
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<Goals>(context, listen: false).fetchGoal(),
        builder: (ctx, snapShot) =>
            (snapShot.connectionState == ConnectionState.waiting)
                ? const Center(
                    child: Text('Goal records are loading!!!'),
                  )
                : Consumer<Goals>(
                    child: const Center(
                        child: Text('No goal has been set. Add some...')),
                    builder: (ctx, goals, ch) => (goals.getGoals.isEmpty)
                        ? ch!
                        : ListView.builder(
                            itemCount: goals.getGoals.length,
                            itemBuilder: (ctx, i) => SingleGoalItem(
                                goals.getGoals[i].id,
                                goals.getGoals[i].title,
                                goals.getGoals[i].savings,
                                goals.getGoals[i].amount,
                                goals.getGoals[i].expiredDate),
                          ),
                  ),
      ),
    );
  }
}
