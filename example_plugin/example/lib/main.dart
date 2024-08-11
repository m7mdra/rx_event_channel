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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Behavior EC'),
              Tab(text: 'Publish EC'),
              Tab(text: 'Replay EC'),
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

  void subscribe() {
    subscription = widget.stream.listen((newData) {
      setState(() {
        list.add(newData);
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _title(context),
          _subtitle(context),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                    onPressed: () {
                      subscribe();
                    },
                    child: const Text('Subscribe')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                    onPressed: () {
                      setState(() {
                        subscription?.cancel();
                        setState(() {
                          list.clear();
                        });
                      });
                    },
                    child: const Text('cancel')),
              ),
            ],
          ),
          Flexible(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Text("item${list[index]}");
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
        text = 'Return only the last event ';
      case ConsumerType.publish:
        text = 'Return only the new event';
      case ConsumerType.replay:
        text = 'Return All event';
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
