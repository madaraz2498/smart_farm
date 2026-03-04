import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SMART FARM CHATBOT SCREEN  — fully theme-driven
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Controller ───────────────────────────────────────────────────────────────

enum ChatStatus { idle, loading, error }

class ChatMessage {
  final String text;
  final bool isUser, isError;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser, this.isError = false})
      : time = DateTime.now();
}

class ChatbotController extends ChangeNotifier {
  final List<ChatMessage> messages = [];
  final messageCtrl = TextEditingController();
  ChatStatus _status   = ChatStatus.idle;
  String     _language = 'English';

  ChatStatus get status   => _status;
  String     get language => _language;

  void setLanguage(String l) { _language = l; notifyListeners(); }

  /// TODO: POST to YOUR_API/chatbot
  /// Body: { message: String, language: String }
  /// Response: { reply: String }
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(text: text.trim(), isUser: true));
    messageCtrl.clear();
    _status = ChatStatus.loading;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      messages.add(ChatMessage(text: _mockReply(text), isUser: false));
      _status = ChatStatus.idle;
    } catch (_) {
      messages.add(ChatMessage(
          text: 'Sorry, I could not respond. Please try again.',
          isUser: false, isError: true));
      _status = ChatStatus.error;
    }
    notifyListeners();
  }

  void clearChat() { messages.clear(); notifyListeners(); }

  String _mockReply(String input) {
    final l = input.toLowerCase();
    if (l.contains('disease'))
      return 'Early blight and late blight are common diseases. Ensure good airflow and avoid overhead watering. Consider a copper-based fungicide.';
    if (l.contains('water') || l.contains('irrigat'))
      return 'Most crops need 1–2 inches of water per week. Drip irrigation is most efficient and keeps foliage dry to reduce disease risk.';
    if (l.contains('fertilizer') || l.contains('soil'))
      return 'A balanced NPK (10-10-10) fertilizer works for most crops. Test your soil pH first — optimal range is usually 6.0–7.0.';
    if (l.contains('pest'))
      return 'Use Integrated Pest Management (IPM). Neem oil works well for soft-bodied insects; ladybugs are great beneficial insects to introduce.';
    if (l.contains('harvest'))
      return 'Harvest in the morning when sugars are highest. Check color, size, and firmness for the specific crop.';
    return 'Great question! For best results, combine AI analysis with advice from your local agricultural extension office. Would you like specific guidance?';
  }

  @override
  void dispose() { messageCtrl.dispose(); super.dispose(); }
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
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeatureAppBar(
        title:   'Smart Farm Chatbot',
        svgPath: 'assets/images/icons/chat_icon.svg',
        actions: [
          // Language EN/AR toggle
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => _ctrl.setLanguage(
                    _ctrl.language == 'English' ? 'Arabic' : 'English'),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: AppRadius.radiusFull,
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _ctrl.language == 'English' ? 'EN' : 'AR',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
          // Clear chat
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => _ctrl.messages.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: _ctrl.clearChat,
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: AppColors.textMuted),
                  ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Column(children: [
          // ── Quick suggestions (when empty) ──────────────────────────
          if (_ctrl.messages.isEmpty)
            _SuggestionsBar(onTap: (s) {
              _ctrl.messageCtrl.text = s;
              _send();
            }),

          // ── Message list ─────────────────────────────────────────────
          Expanded(
            child: _ctrl.messages.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _ctrl.messages.length +
                        (_ctrl.status == ChatStatus.loading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _ctrl.messages.length) {
                        return const _TypingIndicator();
                      }
                      return _Bubble(msg: _ctrl.messages[i]);
                    },
                  ),
          ),

          // ── Input bar ────────────────────────────────────────────────
          _InputBar(ctrl: _ctrl, onSend: _send),
        ]),
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
            color: cs.primaryContainer, borderRadius: AppRadius.radiusXl),
        child: Icon(Icons.chat_bubble_outline_rounded,
            size: 36, color: cs.primary),
      ),
      const SizedBox(height: AppSpacing.lg),
      Text('Ask me anything about farming!', style: tt.titleSmall),
      const SizedBox(height: AppSpacing.xs),
      Text('Crop care, diseases, irrigation, pests...',
          style: tt.bodySmall),
    ]));
  }
}

class _SuggestionsBar extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _SuggestionsBar({required this.onTap});

  static const _suggestions = [
    'How to treat leaf blight?',
    'Best irrigation schedule for wheat',
    'Soil fertilizer recommendations',
    'Common tomato pests',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Quick questions:', style: tt.caption),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => onTap(_suggestions[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color:        cs.primaryContainer,
                  borderRadius: AppRadius.radiusFull,
                  border: Border.all(color: cs.primary.withOpacity(0.3)),
                ),
                child: Text(_suggestions[i],
                    style: tt.labelSmall?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ts = '${msg.time.hour.toString().padLeft(2, '0')}:'
        '${msg.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) _Avatar(isUser: false, cs: cs),
          const SizedBox(width: AppSpacing.sm),
          Flexible(child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: msg.isUser ? cs.primary : cs.surface,
              borderRadius: BorderRadius.only(
                topLeft:     const Radius.circular(AppRadius.lg),
                topRight:    const Radius.circular(AppRadius.lg),
                bottomLeft:  Radius.circular(msg.isUser ? AppRadius.lg : 4),
                bottomRight: Radius.circular(msg.isUser ? 4 : AppRadius.lg),
              ),
              border: msg.isUser ? null : Border.all(color: AppColors.border),
              boxShadow: AppShadows.sm,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(msg.text, style: tt.bodyMedium?.copyWith(
                  color: msg.isUser
                      ? Colors.white
                      : (msg.isError ? AppColors.error : AppColors.textBody),
                  height: 1.5)),
              const SizedBox(height: AppSpacing.xs),
              Text(ts, style: tt.caption?.copyWith(
                  color: msg.isUser
                      ? Colors.white.withOpacity(0.65) : AppColors.textMuted)),
            ]),
          )),
          const SizedBox(width: AppSpacing.sm),
          if (msg.isUser) _Avatar(isUser: true, cs: cs),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final bool isUser; final ColorScheme cs;
  const _Avatar({required this.isUser, required this.cs});

  @override
  Widget build(BuildContext context) => Container(
    width: 32, height: 32,
    decoration: BoxDecoration(
      color: isUser ? cs.primary : cs.primaryContainer,
      shape: BoxShape.circle,
    ),
    child: Icon(
      isUser ? Icons.person_rounded : Icons.smart_toy_outlined,
      size: 16, color: isUser ? Colors.white : cs.primary,
    ),
  );
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _Avatar(isUser: false, cs: cs),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.only(
              topLeft:     Radius.circular(AppRadius.lg),
              topRight:    Radius.circular(AppRadius.lg),
              bottomLeft:  Radius.circular(4),
              bottomRight: Radius.circular(AppRadius.lg),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _Dot(delay: 0, cs: cs),
            const SizedBox(width: AppSpacing.xs),
            _Dot(delay: 200, cs: cs),
            const SizedBox(width: AppSpacing.xs),
            _Dot(delay: 400, cs: cs),
          ]),
        ),
      ]),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay; final ColorScheme cs;
  const _Dot({required this.delay, required this.cs});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ac.repeat(reverse: true);
    });
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 7, height: 7,
      decoration: BoxDecoration(
          color: widget.cs.primary, shape: BoxShape.circle),
    ),
  );
}

class _InputBar extends StatelessWidget {
  final ChatbotController ctrl;
  final VoidCallback onSend;
  const _InputBar({required this.ctrl, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: AppShadows.md,
      ),
      child: Row(children: [
        // ── Text input ───────────────────────────────────────────────
        Expanded(child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.radiusFull,
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: ctrl.messageCtrl,
            minLines: 1, maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: const InputDecoration(
              hintText: 'Ask about crops, diseases, irrigation...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            ),
          ),
        )),
        const SizedBox(width: AppSpacing.sm),

        // ── Send button ──────────────────────────────────────────────
        GestureDetector(
          onTap: ctrl.status == ChatStatus.loading ? null : onSend,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: ctrl.status == ChatStatus.loading
                  ? cs.primary.withOpacity(0.50) : cs.primary,
              shape: BoxShape.circle,
              boxShadow: AppShadows.primaryGlow,
            ),
            child: ctrl.status == ChatStatus.loading
                ? const Padding(padding: EdgeInsets.all(13),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
