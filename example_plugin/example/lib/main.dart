import 'dart:async';

import 'package:example_plugin/example_plugin.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  final plugin = ExamplePlugin();
  final _controller = PreloadPageController();
  late final _tabController = TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:
          ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Behavior'),
              Tab(text: 'Publish'),
              Tab(text: 'Replay'),
            ],
            controller: _tabController,
            onTap: (tab) {
              _controller.jumpToPage(tab);
            },
          ),
        ),
        body: PreloadPageView(
          onPageChanged: (newPage) {
            _tabController.index = newPage;
          },
          controller: _controller,
          children: [
            SubjectConsumerWidget(
              stream: plugin.valuesBehaviorSubject(),
              type: ConsumerType.behavior,
            ),
            SubjectConsumerWidget(
              stream: plugin.valuesPublishSubject(),
              type: ConsumerType.publish,
            ),
            SubjectConsumerWidget(
              stream: plugin.valuesReplaySubject(),
              type: ConsumerType.replay,
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectConsumerWidget extends StatefulWidget {
  final Stream<int> stream;
  final ConsumerType type;

  const SubjectConsumerWidget(
      {super.key, required this.stream, required this.type});

  @override
  State<SubjectConsumerWidget> createState() => _SubjectConsumerWidgetState();
}

class _SubjectConsumerWidgetState extends State<SubjectConsumerWidget>
    with AutomaticKeepAliveClientMixin {
  final list = <int>[];
  StreamSubscription<int>? subscription;
  final _scrollController = ScrollController();
  bool started = false;

  void subscribe() {
    subscription = widget.stream.listen((newData) {
      setState(() {
        started = true;
        list.add(newData);
      });
    });
  }

  void unsubscribe() {
    setState(() {
      list.clear();
      started = false;
    });
    subscription?.cancel();
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _title(context),
                      const Spacer(),
                      Text(
                        '${list.length} Events',
                        style: Theme.of(context).textTheme.labelLarge,
                      )
                    ],
                  ),
                  _subtitle(context),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                            onPressed: started
                                ? null
                                : () {
                                    subscribe();
                                  },
                            child: const Text('Subscribe')),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                            onPressed: started
                                ? () {
                                    setState(() {
                                      unsubscribe();
                                    });
                                  }
                                : null,
                            child: const Text('Cancel')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              controller: _scrollController,
              itemCount: list.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("item ${list[index]}"),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _title(BuildContext context) {
    String text;
    switch (widget.type) {
      case ConsumerType.behavior:
        text = 'Behavior Channel';
      case ConsumerType.publish:
        text = 'Publish Channel';
      case ConsumerType.replay:
        text = 'Replay Channel';
    }
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _subtitle(BuildContext context) {
    String text;
    switch (widget.type) {
      case ConsumerType.behavior:
        text = 'Emits the item most recently emitted by the platform';
      case ConsumerType.publish:
        text =
            'Emits only those items that are emitted by the platform subsequent to the time of the subscription. ';
      case ConsumerType.replay:
        text =
            'Emits All event that were emitted by platform regardless of when the subscription starts.';
    }
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

enum ConsumerType {
  behavior,
  publish,
  replay;
}
