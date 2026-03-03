import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_theme.dart';

// ─── Controller ───────────────────────────────────────────────────────────────

enum ChatStatus { idle, loading, error }

class ChatbotController extends ChangeNotifier {
  final List<ChatMessage> messages = [];
  final messageCtrl = TextEditingController();
  ChatStatus _status = ChatStatus.idle;
  String _language = 'English';

  ChatStatus get status   => _status;
  String     get language => _language;

  void setLanguage(String l) { _language = l; notifyListeners(); }

  /// TODO: POST message to NLP/chatbot API
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(text: text.trim(), isUser: true));
    messageCtrl.clear();
    _status = ChatStatus.loading;
    notifyListeners();
    try {
      // TODO: POST to YOUR_API/chatbot
      // final response = await http.post(Uri.parse('YOUR_API/chatbot'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'message': text, 'language': _language}),
      // );
      // final reply = jsonDecode(response.body)['reply'];
      await Future.delayed(const Duration(milliseconds: 1200));
      final reply = _mockReply(text);
      messages.add(ChatMessage(text: reply, isUser: false));
      _status = ChatStatus.idle;
    } catch (e) {
      _status = ChatStatus.error;
      messages.add(ChatMessage(text: 'Sorry, I could not respond. Please try again.', isUser: false, isError: true));
    }
    notifyListeners();
  }

  void clearChat() { messages.clear(); notifyListeners(); }

  String _mockReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('disease')) return 'Early blight and late blight are common diseases. Ensure good airflow and avoid overhead watering. Consider applying a copper-based fungicide.';
    if (lower.contains('water') || lower.contains('irrigat')) return 'Most crops need 1–2 inches of water per week. Drip irrigation is most efficient and reduces disease risk by keeping foliage dry.';
    if (lower.contains('fertilizer') || lower.contains('soil')) return 'A balanced NPK (10-10-10) fertilizer works for most crops. Test your soil pH first — optimal range is usually 6.0–7.0.';
    if (lower.contains('pest')) return 'Integrated Pest Management (IPM) is recommended. Use neem oil for soft-bodied insects, and introduce beneficial insects like ladybugs.';
    if (lower.contains('harvest')) return 'Harvest timing depends on the crop. For most vegetables, harvest in the morning when sugars are highest. Check color, size, and firmness.';
    return 'Great question! For best results, I recommend consulting your local agricultural extension office alongside AI analysis. Would you like more specific advice on a particular crop or issue?';
  }

  @override
  void dispose() { messageCtrl.dispose(); super.dispose(); }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser, this.isError = false}) : time = DateTime.now();
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl   = ChatbotController();
  final _scroll = ScrollController();

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send() {
    final text = _ctrl.messageCtrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.sendMessage(text).then((_) => _scrollToBottom());
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface, elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark)),
        title: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: Center(child: SvgPicture.asset('assets/images/icons/chat_icon.svg', width: 18, height: 18))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Smart Farm Chatbot', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const Text('AI Agricultural Assistant', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ]),
        ]),
        actions: [
          // Language toggle
          AnimatedBuilder(animation: _ctrl, builder: (_, __) => GestureDetector(
            onTap: () => _ctrl.setLanguage(_ctrl.language == 'English' ? 'Arabic' : 'English'),
            child: Container(margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3))),
              child: Text(_ctrl.language == 'English' ? 'EN' : 'AR',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          )),
          AnimatedBuilder(animation: _ctrl, builder: (_, __) => _ctrl.messages.isEmpty
              ? const SizedBox.shrink()
              : IconButton(onPressed: _ctrl.clearChat,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.textMuted))),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Column(children: [
          // ── Suggestions (only when empty) ──────────────────────────
          if (_ctrl.messages.isEmpty) _SuggestionsPanel(onTap: (s) {
            _ctrl.messageCtrl.text = s;
            _send();
          }),

          // ── Messages ───────────────────────────────────────────────
          Expanded(
            child: _ctrl.messages.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _ctrl.messages.length + (_ctrl.status == ChatStatus.loading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _ctrl.messages.length) return const _TypingIndicator();
                      return _MessageBubble(msg: _ctrl.messages[i]);
                    },
                  ),
          ),

          // ── Input bar ───────────────────────────────────────────────
          _InputBar(ctrl: _ctrl, onSend: _send),
        ]),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 72, height: 72,
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: AppColors.primary)),
    const SizedBox(height: 16),
    const Text('Ask me anything about farming!',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
    const SizedBox(height: 6),
    const Text('Crop care, diseases, irrigation, pests...',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
  ]));
}

class _SuggestionsPanel extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _SuggestionsPanel({required this.onTap});

  static const _suggestions = [
    'How to treat leaf blight?',
    'Best irrigation schedule for wheat',
    'Soil fertilizer recommendations',
    'Common tomato pests',
  ];

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quick questions:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      const SizedBox(height: 8),
      SizedBox(height: 34, child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(_suggestions[i]),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3))),
            child: Text(_suggestions[i], style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500))),
        ),
      )),
    ]),
  );
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!msg.isUser) ...[
          Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.smart_toy_outlined, size: 16, color: AppColors.primary)),
        ],
        Flexible(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: msg.isUser ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
              bottomRight: Radius.circular(msg.isUser ? 4 : 16),
            ),
            border: msg.isUser ? null : Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(msg.text, style: TextStyle(
                fontSize: 14, height: 1.5,
                color: msg.isUser ? Colors.white : (msg.isError ? const Color(0xFFEF4444) : AppColors.textDark))),
            const SizedBox(height: 4),
            Text('${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 10,
                    color: msg.isUser ? Colors.white.withOpacity(0.7) : AppColors.textMuted)),
          ]),
        )),
        if (msg.isUser) ...[
          Container(width: 32, height: 32, margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, size: 16, color: Colors.white)),
        ],
      ],
    ),
  );
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.smart_toy_outlined, size: 16, color: AppColors.primary)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16)),
            border: Border.all(color: AppColors.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _Dot(delay: 0), const SizedBox(width: 4),
          _Dot(delay: 200), const SizedBox(width: 4),
          _Dot(delay: 400),
        ]),
      ),
    ]),
  );
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ac.repeat(reverse: true);
    });
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
  );
}

class _InputBar extends StatelessWidget {
  final ChatbotController ctrl;
  final VoidCallback onSend;
  const _InputBar({required this.ctrl, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.border)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, -2))],
    ),
    child: Row(children: [
      Expanded(child: Container(
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border)),
        child: TextField(
          controller: ctrl.messageCtrl,
          minLines: 1, maxLines: 4,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => onSend(),
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: const InputDecoration(
            hintText: 'Ask about crops, diseases, irrigation...',
            hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      )),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: ctrl.status == ChatStatus.loading ? null : onSend,
        child: AnimatedContainer(duration: const Duration(milliseconds: 200),
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: ctrl.status == ChatStatus.loading ? AppColors.primary.withOpacity(0.5) : AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: ctrl.status == ChatStatus.loading
              ? const Padding(padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
      ),
    ]),
  );
}
