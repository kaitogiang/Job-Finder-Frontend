import 'package:flutter/material.dart';
import 'package:job_finder_app/models/user.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:go_router/go_router.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with AutomaticKeepAliveClientMixin<MessageScreen> {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    Utils.logMessage('dispose message screen');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Utils.logMessage('build message screen');
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final user = User(
      id: '1',
      firstName: 'Devin',
      lastName: 'Glover',
      email: 'devin@example.com',
      phone: '1234567890',
      address: '1234 Main St, Anytown, USA',
      avatar:
          'https://www.dexerto.com/cdn-cgi/image/width=3840,quality=60,format=auto/https://editors.dexerto.com/wp-content/uploads/2022/08/25/nilou-eyes-closed-genshin-impact.jpg',
    );
    final user2 = User(
      id: '2',
      firstName: 'Gojo',
      lastName: 'Satoru',
      email: 'devin@example.com',
      phone: '1234567890',
      address: '1234 Main St, Anytown, USA',
      avatar: 'https://pics.craiyon.com/2023-11-20/Ud5thxsrQ16T6n0TDZ6BsA.webp',
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Tin nhắn của bạn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          width: deviceSize.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.blueAccent.shade700,
                Colors.blueAccent.shade400,
                theme.primaryColor,
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onTap: () {},
                  decoration: InputDecoration(
                    constraints: BoxConstraints.tightFor(height: 60),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    hintText: 'Tìm kiếm tin nhắn của bạn tại đây',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (value) async {},
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ChatPreviewCard(
            user: user,
            lastMessage: 'Hẹn ngày mai gặp tại phòng họp adfa dfa ',
            dateTime: '10:30 AM',
            unseenMessages: 0,
          ),
          ChatPreviewCard(
            user: user2,
            lastMessage: 'Hẹn ngày mai gặp tại phòng họp adfa dfa ',
            dateTime: '7:30 AM',
            unseenMessages: 7,
          ),
        ],
      ),
    );
  }
}

class ChatPreviewCard extends StatelessWidget {
  const ChatPreviewCard({
    super.key,
    required this.user,
    required this.lastMessage,
    required this.dateTime,
    required this.unseenMessages,
  });

  final User user;
  final String lastMessage;
  final String dateTime;
  final int unseenMessages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return ListTile(
      onTap: () {
        context.pushNamed('chat');
      },
      onLongPress: () {
        Utils.logMessage('Tùy chọn cuộc trò chuyện');
      },
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(user.avatar),
      ),
      title: Text(
        '${user.firstName} ${user.lastName}',
        style: textTheme.bodyLarge!.copyWith(
          fontWeight: unseenMessages > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyMedium!.copyWith(
          fontWeight: unseenMessages > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dateTime,
            style: textTheme.bodySmall!.copyWith(
              fontWeight:
                  unseenMessages > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 5),
          if (unseenMessages > 0)
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.blue,
              child: Text(
                unseenMessages.toString(),
                style:
                    textTheme.bodySmall!.copyWith(color: theme.indicatorColor),
              ),
            )
        ],
      ),
    );
  }
}
