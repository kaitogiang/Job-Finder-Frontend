import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/main.dart';
import 'package:job_finder_app/models/conversation.dart';
import 'package:job_finder_app/models/user.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/shared/message_manager.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  List<Conversation> conversations = [];

  @override
  void initState() {
    super.initState();
    // Gọi hàm khởi tạo dữ liệu conversation khi widget được khởi tạo
    // Sử dụng addPostFrameCallback để đảm bảo rằng hàm getAllJobseekerConversation
    // được gọi sau khi khung hình hiện tại đã hoàn thành, tránh việc gọi hàm này
    // trong quá trình xây dựng widget, giúp tránh các lỗi liên quan đến việc
    // thay đổi trạng thái trong quá trình xây dựng.
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await context.read<MessageManager>().getAllConversation();
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    final messageManager = context.watch<MessageManager>();
    final isEmployer = context.read<AuthManager>().isEmployer;
    conversations = messageManager.conversations;
    Utils.logMessage('conversations: ${conversations.length}');
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
      body: RefreshIndicator(
        onRefresh: () => context.read<MessageManager>().getAllConversation(),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          child: ListView.builder(
            itemCount: messageManager.conversations.length,
            itemBuilder: (context, index) {
              final conversation = messageManager.conversations[index];
              return conversation.messages.isEmpty
                  ? const SizedBox.shrink()
                  : ChatPreviewCard(
                      conversation: conversation,
                      isEmployer: isEmployer,
                    );
            },
          ),
        ),
      ),
    );
  }
}

class ChatPreviewCard extends StatelessWidget {
  const ChatPreviewCard({
    super.key,
    required this.conversation,
    required this.isEmployer,
  });

  final Conversation conversation;
  final bool isEmployer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final user = isEmployer ? conversation.jobseeker : conversation.employer;
    final lastMessage = conversation.lastMessage;
    final dateTime = DateFormat('hh:mm a').format(conversation.lastMessageTime);
    final unseenMessages = isEmployer
        ? conversation.unseenEmployerMessages
        : conversation.unseenJobseekerMessages;
    return ListTile(
      onTap: () {
        context.pushNamed('chat', extra: conversation.id);
      },
      onLongPress: () {
        Utils.logMessage('Tùy chọn cuộc trò chuyện');
      },
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(user.getImageUrl()),
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
