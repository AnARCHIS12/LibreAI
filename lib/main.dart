import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

const _mistralApiKey = String.fromEnvironment('MISTRAL_API_KEY');
const _mistralModel = String.fromEnvironment(
  'MISTRAL_MODEL',
  defaultValue: 'mistral-small-latest',
);
const _imageGenerationModel = 'mistral-medium-latest';
const _ink = Color(0xFF15151B);
const _paper = Color(0xFFFAFAF7);
const _mist = Color(0xFFF0F4F3);
const _coral = Color(0xFFFF5A3D);
const _amber = Color(0xFFF7B733);
const _cyan = Color(0xFF16C7C7);
final Uri _mistralApiKeysUri = Uri.parse('https://console.mistral.ai/api-keys');

String t(String languageCode, String key) {
  return _translations[languageCode]?[key] ?? _translations['fr']?[key] ?? key;
}

ThemeMode themeModeFromName(String value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

String themeModeName(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}

const _translations = {
  'fr': {
    'tagline': 'assistant prive',
    'newConversation': 'Nouvelle conversation',
    'history': 'Historique',
    'settings': 'Parametres',
    'chat': 'Chat',
    'library': 'Bibliotheque',
    'theme': 'Theme',
    'themeSystem': 'Systeme',
    'themeLight': 'Clair',
    'themeDark': 'Sombre',
    'recentChats': 'Conversations recentes',
    'memoryPanel': 'Memoire',
    'toolbox': 'Outils',
    'imageToolDesc': 'Creer une image depuis un prompt.',
    'ocrToolDesc': 'Extraire le texte de PDF, images et documents.',
    'audioToolDesc': 'Transcrire un fichier audio avec Voxtral.',
    'localActions': 'Actions locales',
    'clearLocalData': 'Effacer donnees locales',
    'missingApiKey': 'Cle API Mistral manquante.',
    'localKey': 'Cle locale',
    'missingKeyShort': 'Cle absente',
    'localMemory': 'Memoire locale',
    'emptyMemory': 'Memoire vide',
    'loading': 'Chargement',
    'networkError': 'Erreur reseau inattendue.',
    'toolError': 'Erreur outil inattendue.',
    'dictationUnavailable': 'Dictee vocale indisponible',
    'dictationUnavailableDevice':
        'Dictee vocale non disponible sur cet appareil.',
    'startNewThread': 'Demarrer un nouveau fil',
    'apiKey': 'Cle API Mistral',
    'getApiKey': 'Obtenir une cle API Mistral',
    'getApiKeyHelp': 'Ouvre le site officiel Mistral Studio',
    'language': 'Langue',
    'model': 'Modele',
    'memory': 'Memoire locale',
    'save': 'Enregistrer',
    'loadingModels': 'Chargement des modeles',
    'fetchModels': 'Recuperer les modeles Mistral',
    'loadModelsHint': 'Charge la liste depuis Mistral',
    'generateImage': 'Generer une image',
    'generateImageShort': 'Generer image',
    'imagePrompt': 'Prompt image',
    'generate': 'Generer',
    'tools': 'Outils',
    'ocrFile': 'OCR PDF / fichier',
    'transcribeAudio': 'Transcrire audio',
    'message': 'Message',
    'dictation': 'Dictee vocale',
    'stopDictation': 'Arreter la dictee',
    'noTextExtracted': 'Aucun texte extrait.',
    'noTranscription': 'Aucune transcription recue.',
    'noMessages': 'Aucun message',
  },
  'en': {
    'tagline': 'private assistant',
    'newConversation': 'New chat',
    'history': 'History',
    'settings': 'Settings',
    'chat': 'Chat',
    'library': 'Library',
    'theme': 'Theme',
    'themeSystem': 'System',
    'themeLight': 'Light',
    'themeDark': 'Dark',
    'recentChats': 'Recent chats',
    'memoryPanel': 'Memory',
    'toolbox': 'Tools',
    'imageToolDesc': 'Create an image from a prompt.',
    'ocrToolDesc': 'Extract text from PDFs, images, and documents.',
    'audioToolDesc': 'Transcribe an audio file with Voxtral.',
    'localActions': 'Local actions',
    'clearLocalData': 'Clear local data',
    'missingApiKey': 'Mistral API key missing.',
    'localKey': 'Local key',
    'missingKeyShort': 'No key',
    'localMemory': 'Local memory',
    'emptyMemory': 'Empty memory',
    'loading': 'Loading',
    'networkError': 'Unexpected network error.',
    'toolError': 'Unexpected tool error.',
    'dictationUnavailable': 'Voice dictation unavailable',
    'dictationUnavailableDevice':
        'Voice dictation is not available on this device.',
    'startNewThread': 'Start a new thread',
    'apiKey': 'Mistral API key',
    'getApiKey': 'Get a Mistral API key',
    'getApiKeyHelp': 'Opens the official Mistral Studio website',
    'language': 'Language',
    'model': 'Model',
    'memory': 'Local memory',
    'save': 'Save',
    'loadingModels': 'Loading models',
    'fetchModels': 'Fetch Mistral models',
    'loadModelsHint': 'Load the list from Mistral',
    'generateImage': 'Generate an image',
    'generateImageShort': 'Generate image',
    'imagePrompt': 'Image prompt',
    'generate': 'Generate',
    'tools': 'Tools',
    'ocrFile': 'OCR PDF / file',
    'transcribeAudio': 'Transcribe audio',
    'message': 'Message',
    'dictation': 'Voice dictation',
    'stopDictation': 'Stop dictation',
    'noTextExtracted': 'No text extracted.',
    'noTranscription': 'No transcription received.',
    'noMessages': 'No messages',
  },
  'es': {
    'tagline': 'asistente privado',
    'newConversation': 'Nueva conversacion',
    'history': 'Historial',
    'settings': 'Ajustes',
    'chat': 'Chat',
    'library': 'Biblioteca',
    'theme': 'Tema',
    'themeSystem': 'Sistema',
    'themeLight': 'Claro',
    'themeDark': 'Oscuro',
    'recentChats': 'Conversaciones recientes',
    'memoryPanel': 'Memoria',
    'toolbox': 'Herramientas',
    'imageToolDesc': 'Crear una imagen desde un prompt.',
    'ocrToolDesc': 'Extraer texto de PDF, imagenes y documentos.',
    'audioToolDesc': 'Transcribir un archivo de audio con Voxtral.',
    'localActions': 'Acciones locales',
    'clearLocalData': 'Borrar datos locales',
    'missingApiKey': 'Falta la clave API de Mistral.',
    'localKey': 'Clave local',
    'missingKeyShort': 'Sin clave',
    'localMemory': 'Memoria local',
    'emptyMemory': 'Memoria vacia',
    'loading': 'Cargando',
    'networkError': 'Error de red inesperado.',
    'toolError': 'Error inesperado de herramienta.',
    'dictationUnavailable': 'Dictado de voz no disponible',
    'dictationUnavailableDevice':
        'El dictado de voz no esta disponible en este dispositivo.',
    'startNewThread': 'Iniciar nuevo hilo',
    'apiKey': 'Clave API Mistral',
    'getApiKey': 'Obtener una clave API Mistral',
    'getApiKeyHelp': 'Abre el sitio oficial de Mistral Studio',
    'language': 'Idioma',
    'model': 'Modelo',
    'memory': 'Memoria local',
    'save': 'Guardar',
    'loadingModels': 'Cargando modelos',
    'fetchModels': 'Recuperar modelos Mistral',
    'loadModelsHint': 'Carga la lista desde Mistral',
    'generateImage': 'Generar una imagen',
    'generateImageShort': 'Generar imagen',
    'imagePrompt': 'Prompt de imagen',
    'generate': 'Generar',
    'tools': 'Herramientas',
    'ocrFile': 'OCR PDF / archivo',
    'transcribeAudio': 'Transcribir audio',
    'message': 'Mensaje',
    'dictation': 'Dictado de voz',
    'stopDictation': 'Detener dictado',
    'noTextExtracted': 'No se extrajo texto.',
    'noTranscription': 'No se recibio transcripcion.',
    'noMessages': 'Sin mensajes',
  },
  'ar': {
    'tagline': 'مساعد خاص',
    'newConversation': 'محادثة جديدة',
    'history': 'السجل',
    'settings': 'الإعدادات',
    'chat': 'المحادثة',
    'library': 'المكتبة',
    'theme': 'السمة',
    'themeSystem': 'النظام',
    'themeLight': 'فاتح',
    'themeDark': 'داكن',
    'recentChats': 'المحادثات الأخيرة',
    'memoryPanel': 'الذاكرة',
    'toolbox': 'الأدوات',
    'imageToolDesc': 'إنشاء صورة من وصف.',
    'ocrToolDesc': 'استخراج النص من PDF والصور والمستندات.',
    'audioToolDesc': 'تفريغ ملف صوتي باستخدام Voxtral.',
    'localActions': 'إجراءات محلية',
    'clearLocalData': 'مسح البيانات المحلية',
    'missingApiKey': 'مفتاح Mistral API مفقود.',
    'localKey': 'مفتاح محلي',
    'missingKeyShort': 'لا يوجد مفتاح',
    'localMemory': 'ذاكرة محلية',
    'emptyMemory': 'ذاكرة فارغة',
    'loading': 'تحميل',
    'networkError': 'خطأ شبكة غير متوقع.',
    'toolError': 'خطأ غير متوقع في الأداة.',
    'dictationUnavailable': 'الإملاء الصوتي غير متاح',
    'dictationUnavailableDevice': 'الإملاء الصوتي غير متاح على هذا الجهاز.',
    'startNewThread': 'بدء محادثة جديدة',
    'apiKey': 'مفتاح Mistral API',
    'getApiKey': 'الحصول على مفتاح Mistral API',
    'getApiKeyHelp': 'يفتح موقع Mistral Studio الرسمي',
    'language': 'اللغة',
    'model': 'النموذج',
    'memory': 'الذاكرة المحلية',
    'save': 'حفظ',
    'loadingModels': 'تحميل النماذج',
    'fetchModels': 'جلب نماذج Mistral',
    'loadModelsHint': 'حمّل القائمة من Mistral',
    'generateImage': 'إنشاء صورة',
    'generateImageShort': 'إنشاء صورة',
    'imagePrompt': 'وصف الصورة',
    'generate': 'إنشاء',
    'tools': 'الأدوات',
    'ocrFile': 'OCR PDF / ملف',
    'transcribeAudio': 'تفريغ الصوت',
    'message': 'رسالة',
    'dictation': 'إملاء صوتي',
    'stopDictation': 'إيقاف الإملاء',
    'noTextExtracted': 'لم يتم استخراج نص.',
    'noTranscription': 'لم يصل أي تفريغ.',
    'noMessages': 'لا توجد رسائل',
  },
};

void main() {
  runApp(const LibreAiApp());
}

class LibreAiApp extends StatefulWidget {
  const LibreAiApp({super.key, AppStorage? storage})
    : storage = storage ?? const DeviceAppStorage();

  final AppStorage storage;

  @override
  State<LibreAiApp> createState() => _LibreAiAppState();
}

class _LibreAiAppState extends State<LibreAiApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final saved = await widget.storage.loadThemeMode();
    if (!mounted) {
      return;
    }
    setState(() {
      _themeMode = themeModeFromName(saved);
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    await widget.storage.saveThemeMode(themeModeName(mode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Libre AI',
      themeMode: _themeMode,
      theme: buildLibreTheme(Brightness.light),
      darkTheme: buildLibreTheme(Brightness.dark),
      home: ChatScreen(
        storage: widget.storage,
        client: MistralClient(),
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

ThemeData buildLibreTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: _coral,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: isDark ? const Color(0xFF101114) : _paper,
    textTheme: Typography.material2021().black.apply(
      bodyColor: isDark ? const Color(0xFFF5F2EA) : _ink,
      displayColor: isDark ? const Color(0xFFF5F2EA) : _ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? const Color(0xFF101114) : _paper,
      foregroundColor: isDark ? const Color(0xFFF5F2EA) : _ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: isDark ? const Color(0xFF15161A) : Colors.white,
      selectedIconTheme: const IconThemeData(color: _coral),
      selectedLabelTextStyle: const TextStyle(
        color: _coral,
        fontWeight: FontWeight.w800,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF15161A) : Colors.white,
      indicatorColor: _coral.withAlpha(30),
    ),
  );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.storage,
    required this.client,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final AppStorage storage;
  final MistralClient client;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePromptController = TextEditingController();
  final _speech = stt.SpeechToText();
  String _apiKey = _mistralApiKey;
  String _model = _mistralModel;
  String _localMemory = '';
  String _languageCode = 'fr';
  String _currentConversationId = '';
  String _dictationSeed = '';
  _AppSection _section = _AppSection.chat;
  List<ChatConversation> _conversations = const [];
  final List<ChatMessage> _messages = [];

  bool _isSending = false;
  bool _isRunningTool = false;
  bool _isLoadingLocalData = true;
  bool _isListening = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    _imagePromptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _hasApiKey => _apiKey.trim().isNotEmpty;
  bool get _isRtl => _languageCode == 'ar';
  String _t(String key) => t(_languageCode, key);

  Future<void> _loadLocalData() async {
    var apiKey = await widget.storage.loadApiKey();
    if (apiKey.isEmpty && _mistralApiKey.isNotEmpty) {
      apiKey = _mistralApiKey;
      await widget.storage.saveApiKey(apiKey);
    }

    final model = await widget.storage.loadModel();
    final localMemory = await widget.storage.loadLocalMemory();
    final languageCode = await widget.storage.loadLanguageCode();
    final messages = await widget.storage.loadMessages();
    var conversations = await widget.storage.loadConversations();
    var currentConversationId = await widget.storage
        .loadCurrentConversationId();

    if (conversations.isEmpty) {
      final initialMessages = messages;
      final initialConversation = ChatConversation(
        id: _newConversationId(),
        title: _titleForMessages(initialMessages),
        updatedAt: DateTime.now(),
        messages: initialMessages,
      );
      conversations = [initialConversation];
      currentConversationId = initialConversation.id;
      await widget.storage.saveConversations(conversations);
      await widget.storage.saveCurrentConversationId(currentConversationId);
    }

    final currentConversation = conversations.firstWhere(
      (conversation) => conversation.id == currentConversationId,
      orElse: () => conversations.first,
    );
    currentConversationId = currentConversation.id;

    if (!mounted) {
      return;
    }

    setState(() {
      _apiKey = apiKey;
      _model = model.isEmpty ? _mistralModel : model;
      _localMemory = localMemory;
      _languageCode = languageCode.isEmpty ? 'fr' : languageCode;
      _conversations = conversations;
      _currentConversationId = currentConversationId;
      _messages
        ..clear()
        ..addAll(currentConversation.messages);
      _isLoadingLocalData = false;
    });

    if (model.isEmpty) {
      await widget.storage.saveModel(_model);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isBusy || !_hasApiKey) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, content: text));
      _controller.clear();
      _isSending = true;
      _error = null;
    });
    await _persistCurrentConversation();
    _scrollToBottom();

    try {
      final answer = await widget.client.complete(
        apiKey: _apiKey,
        model: _model,
        localMemory: _localMemory,
        messages: _messages,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _messages.add(ChatMessage(role: ChatRole.assistant, content: answer));
      });
      await _persistCurrentConversation();
      await _updateAdaptiveMemory();
    } on MistralException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _t('networkError');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  bool get _isBusy => _isSending || _isRunningTool;

  Future<void> _toggleDictation() async {
    if (_isBusy) {
      return;
    }

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) {
          return;
        }
        if (status == stt.SpeechToText.notListeningStatus ||
            status == stt.SpeechToText.doneStatus) {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isListening = false;
          _error = '${_t('dictationUnavailable')}: ${error.errorMsg}';
        });
      },
    );

    if (!available) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _t('dictationUnavailableDevice');
      });
      return;
    }

    _dictationSeed = _controller.text.trim();
    setState(() {
      _isListening = true;
      _error = null;
    });

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 4),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
      ),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognized = result.recognizedWords.trim();
    if (recognized.isEmpty) {
      return;
    }

    final text = _dictationSeed.isEmpty
        ? recognized
        : '$_dictationSeed $recognized';
    _controller
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
  }

  Future<void> _runTool(_ToolAction action) async {
    if (!_hasApiKey || _isBusy) {
      return;
    }

    switch (action) {
      case _ToolAction.image:
        await _generateImage();
      case _ToolAction.ocr:
        await _runOcr();
      case _ToolAction.audio:
        await _transcribeAudio();
    }
  }

  Future<void> _generateImage() async {
    final prompt = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ImagePromptSheet(
        controller: _imagePromptController,
        languageCode: _languageCode,
      ),
    );

    if (prompt == null || prompt.trim().isEmpty || !mounted) {
      return;
    }

    await _withToolProgress(
      userMessage: 'Image: $prompt',
      task: () async {
        final result = await widget.client.generateImage(
          apiKey: _apiKey,
          model: _imageGenerationModel,
          prompt: prompt,
        );
        final imagePath = await _saveGeneratedImage(result.bytes);
        _messages.add(
          ChatMessage(
            role: ChatRole.assistant,
            content: result.text.isEmpty ? 'Image generee.' : result.text,
            imagePath: imagePath,
          ),
        );
      },
    );
  }

  Future<void> _runOcr() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp', 'docx', 'pptx'],
      withData: false,
    );
    final file = picked?.files.single;
    final path = file?.path;
    if (file == null || path == null || !mounted) {
      return;
    }

    await _withToolProgress(
      userMessage: 'OCR: ${file.name}',
      task: () async {
        final markdown = await widget.client.ocrFile(
          apiKey: _apiKey,
          path: path,
          fileName: file.name,
        );
        _messages.add(
          ChatMessage(
            role: ChatRole.assistant,
            content: markdown.isEmpty ? _t('noTextExtracted') : markdown,
          ),
        );
      },
    );
  }

  Future<void> _transcribeAudio() async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'ogg', 'flac', 'webm', 'mp4'],
      withData: false,
    );
    final file = picked?.files.single;
    final path = file?.path;
    if (file == null || path == null || !mounted) {
      return;
    }

    await _withToolProgress(
      userMessage: 'Transcription: ${file.name}',
      task: () async {
        final text = await widget.client.transcribeAudio(
          apiKey: _apiKey,
          path: path,
          fileName: file.name,
        );
        _messages.add(
          ChatMessage(
            role: ChatRole.assistant,
            content: text.isEmpty ? _t('noTranscription') : text,
          ),
        );
      },
    );
  }

  Future<void> _withToolProgress({
    required String userMessage,
    required Future<void> Function() task,
  }) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, content: userMessage));
      _isRunningTool = true;
      _error = null;
    });
    await _persistCurrentConversation();
    _scrollToBottom();

    try {
      await task();
      await _persistCurrentConversation();
      await _updateAdaptiveMemory();
    } on MistralException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _t('toolError');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunningTool = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<String> _saveGeneratedImage(List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/mistral_image_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> _newConversation() async {
    final conversation = ChatConversation(
      id: _newConversationId(),
      title: _t('newConversation'),
      updatedAt: DateTime.now(),
      messages: const [],
    );

    setState(() {
      _currentConversationId = conversation.id;
      _conversations = [conversation, ..._conversations];
      _messages
        ..clear()
        ..addAll(conversation.messages);
      _error = null;
    });
    await widget.storage.saveConversations(_conversations);
    await widget.storage.saveCurrentConversationId(_currentConversationId);
    await widget.storage.saveMessages(_messages);
    _scrollToBottom();
  }

  Future<void> _openHistory() async {
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _HistorySheet(
        conversations: _conversations,
        currentConversationId: _currentConversationId,
        languageCode: _languageCode,
      ),
    );

    if (selectedId == null || !mounted) {
      return;
    }

    if (selectedId == '__new__') {
      await _newConversation();
      return;
    }

    final conversation = _conversations.firstWhere(
      (conversation) => conversation.id == selectedId,
      orElse: () => _conversations.first,
    );

    setState(() {
      _currentConversationId = conversation.id;
      _messages
        ..clear()
        ..addAll(conversation.messages);
      _error = null;
    });
    await widget.storage.saveCurrentConversationId(conversation.id);
    await widget.storage.saveMessages(_messages);
    _scrollToBottom();
  }

  Future<void> _openSettings() async {
    final result = await showModalBottomSheet<SettingsResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _SettingsSheet(
        apiKey: _apiKey,
        model: _model,
        localMemory: _localMemory,
        languageCode: _languageCode,
        themeMode: widget.themeMode,
        client: widget.client,
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _apiKey = result.apiKey;
      _model = result.model;
      _localMemory = result.localMemory;
      _languageCode = result.languageCode;
      _error = null;
    });

    await widget.storage.saveApiKey(result.apiKey);
    await widget.storage.saveModel(result.model);
    await widget.storage.saveLocalMemory(result.localMemory);
    await widget.storage.saveLanguageCode(result.languageCode);
    widget.onThemeModeChanged(result.themeMode);
  }

  Future<void> _clearLocalData() async {
    await widget.storage.clearAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _apiKey = '';
      _model = _mistralModel;
      _localMemory = '';
      _languageCode = 'fr';
      _currentConversationId = _newConversationId();
      _conversations = [
        ChatConversation(
          id: _currentConversationId,
          title: _t('newConversation'),
          updatedAt: DateTime.now(),
          messages: const [],
        ),
      ];
      _messages
        ..clear()
        ..clear();
      _error = null;
    });
  }

  Future<void> _persistCurrentConversation() async {
    final now = DateTime.now();
    final conversation = ChatConversation(
      id: _currentConversationId.isEmpty
          ? _newConversationId()
          : _currentConversationId,
      title: _titleForMessages(_messages),
      updatedAt: now,
      messages: List.of(_messages),
    );

    final conversations = [
      conversation,
      ..._conversations.where((item) => item.id != conversation.id),
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    setState(() {
      _currentConversationId = conversation.id;
      _conversations = conversations;
    });

    await widget.storage.saveConversations(conversations);
    await widget.storage.saveCurrentConversationId(conversation.id);
    await widget.storage.saveMessages(_messages);
  }

  Future<void> _updateAdaptiveMemory() async {
    if (!_hasApiKey) {
      return;
    }

    try {
      final updatedMemory = await widget.client.updateMemory(
        apiKey: _apiKey,
        model: _model,
        currentMemory: _localMemory,
        messages: _messages,
      );
      if (!mounted || updatedMemory.trim() == _localMemory.trim()) {
        return;
      }
      setState(() {
        _localMemory = updatedMemory.trim();
      });
      await widget.storage.saveLocalMemory(_localMemory);
    } catch (_) {
      // Memory updates are helpful, but they should never interrupt the chat.
    }
  }

  String _newConversationId() {
    return 'chat_${DateTime.now().microsecondsSinceEpoch}';
  }

  String _titleForMessages(List<ChatMessage> messages) {
    String? firstUserMessage;
    for (final message in messages) {
      if (message.role != ChatRole.user) {
        continue;
      }
      final content = message.content.trim();
      if (content.isNotEmpty) {
        firstUserMessage = content;
        break;
      }
    }

    if (firstUserMessage == null) {
      return _t('newConversation');
    }
    if (firstUserMessage.length <= 48) {
      return firstUserMessage;
    }
    return '${firstUserMessage.substring(0, 48)}...';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 820;
    final background = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF101114)
        : _paper;

    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 68,
          titleSpacing: 16,
          title: _BrandTitle(subtitle: _t('tagline')),
          centerTitle: false,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE8E3DA)),
          ),
          actions: [
            Tooltip(
              message: _t('newConversation'),
              child: IconButton(
                onPressed: _isBusy ? null : _newConversation,
                icon: const Icon(Icons.add_comment_outlined),
              ),
            ),
            Tooltip(
              message: _t('history'),
              child: IconButton(
                onPressed: _isBusy ? null : _openHistory,
                icon: const Icon(Icons.history_rounded),
              ),
            ),
            Tooltip(
              message: _t('settings'),
              child: IconButton(
                onPressed: _isBusy ? null : _openSettings,
                icon: const Icon(Icons.tune_rounded),
              ),
            ),
            PopupMenuButton<_LocalAction>(
              tooltip: _t('localActions'),
              onSelected: (action) {
                if (action == _LocalAction.clearAll) {
                  _clearLocalData();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _LocalAction.clearAll,
                  child: Text(_t('clearLocalData')),
                ),
              ],
            ),
          ],
        ),
        body: DecoratedBox(
          decoration: BoxDecoration(color: background),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                if (isWide)
                  _SideNavigation(
                    section: _section,
                    languageCode: _languageCode,
                    onChanged: (section) => setState(() {
                      _section = section;
                    }),
                  ),
                Expanded(child: _buildSection()),
              ],
            ),
          ),
        ),
        bottomNavigationBar: isWide
            ? null
            : _BottomAppNavigation(
                section: _section,
                languageCode: _languageCode,
                onChanged: (section) => setState(() {
                  _section = section;
                }),
              ),
      ),
    );
  }

  Widget _buildSection() {
    switch (_section) {
      case _AppSection.chat:
        return _ChatPage(
          model: _model,
          hasApiKey: _hasApiKey,
          hasMemory: _localMemory.trim().isNotEmpty,
          isLoadingLocalData: _isLoadingLocalData,
          error: _error,
          messages: _messages,
          isBusy: _isBusy,
          scrollController: _scrollController,
          composer: _MessageComposer(
            controller: _controller,
            enabled: _hasApiKey && !_isBusy && !_isLoadingLocalData,
            isSending: _isBusy,
            isListening: _isListening,
            onSend: _sendMessage,
            onDictation: _toggleDictation,
            onToolSelected: _runTool,
            languageCode: _languageCode,
          ),
          languageCode: _languageCode,
        );
      case _AppSection.library:
        return _LibraryPage(
          conversations: _conversations,
          currentConversationId: _currentConversationId,
          localMemory: _localMemory,
          languageCode: _languageCode,
          onNewConversation: _newConversation,
          onOpenConversation: (id) async {
            final conversation = _conversations.firstWhere(
              (conversation) => conversation.id == id,
              orElse: () => _conversations.first,
            );
            setState(() {
              _section = _AppSection.chat;
              _currentConversationId = conversation.id;
              _messages
                ..clear()
                ..addAll(conversation.messages);
              _error = null;
            });
            await widget.storage.saveCurrentConversationId(conversation.id);
            await widget.storage.saveMessages(_messages);
            _scrollToBottom();
          },
        );
      case _AppSection.tools:
        return _ToolsPage(
          languageCode: _languageCode,
          enabled: _hasApiKey && !_isBusy,
          onToolSelected: _runTool,
        );
    }
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _BrandMark(size: 40),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Libre AI',
              style: TextStyle(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                height: 1,
                color: Color(0xFF67625D),
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _BrandMarkPainter()),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(size.width * 0.02),
      Radius.circular(size.width * 0.24),
    );
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_ink, Color(0xFF2B2239), _coral],
        stops: [0, 0.55, 1],
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [_cyan.withAlpha(170), Colors.transparent],
      ).createShader(rect);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.24),
      size.width * 0.46,
      glowPaint,
    );

    final cat = Path()
      ..moveTo(size.width * 0.24, size.height * 0.56)
      ..lineTo(size.width * 0.30, size.height * 0.28)
      ..lineTo(size.width * 0.46, size.height * 0.42)
      ..lineTo(size.width * 0.55, size.height * 0.42)
      ..lineTo(size.width * 0.70, size.height * 0.28)
      ..lineTo(size.width * 0.76, size.height * 0.56)
      ..quadraticBezierTo(
        size.width * 0.74,
        size.height * 0.76,
        size.width * 0.50,
        size.height * 0.80,
      )
      ..quadraticBezierTo(
        size.width * 0.26,
        size.height * 0.76,
        size.width * 0.24,
        size.height * 0.56,
      )
      ..close();

    canvas.drawPath(cat, Paint()..color = const Color(0xFFFFF7E6));

    final stripePaint = Paint()
      ..color = _coral
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.36, size.height * 0.56),
      Offset(size.width * 0.64, size.height * 0.56),
      stripePaint,
    );
    stripePaint.color = _amber;
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.66),
      Offset(size.width * 0.58, size.height * 0.66),
      stripePaint,
    );

    final eyePaint = Paint()..color = _ink;
    canvas.drawCircle(
      Offset(size.width * 0.40, size.height * 0.49),
      size.width * 0.035,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.60, size.height * 0.49),
      size.width * 0.035,
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({
    required this.section,
    required this.languageCode,
    required this.onChanged,
  });

  final _AppSection section;
  final String languageCode;
  final ValueChanged<_AppSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: section.index,
      onDestinationSelected: (index) => onChanged(_AppSection.values[index]),
      labelType: NavigationRailLabelType.all,
      minWidth: 92,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.chat_bubble_outline),
          selectedIcon: const Icon(Icons.chat_bubble),
          label: Text(t(languageCode, 'chat')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.library_books_outlined),
          selectedIcon: const Icon(Icons.library_books),
          label: Text(t(languageCode, 'library')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.auto_fix_high_outlined),
          selectedIcon: const Icon(Icons.auto_fix_high),
          label: Text(t(languageCode, 'tools')),
        ),
      ],
    );
  }
}

class _BottomAppNavigation extends StatelessWidget {
  const _BottomAppNavigation({
    required this.section,
    required this.languageCode,
    required this.onChanged,
  });

  final _AppSection section;
  final String languageCode;
  final ValueChanged<_AppSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: section.index,
      onDestinationSelected: (index) => onChanged(_AppSection.values[index]),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.chat_bubble_outline),
          selectedIcon: const Icon(Icons.chat_bubble),
          label: t(languageCode, 'chat'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.library_books_outlined),
          selectedIcon: const Icon(Icons.library_books),
          label: t(languageCode, 'library'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.auto_fix_high_outlined),
          selectedIcon: const Icon(Icons.auto_fix_high),
          label: t(languageCode, 'tools'),
        ),
      ],
    );
  }
}

class _ChatPage extends StatelessWidget {
  const _ChatPage({
    required this.model,
    required this.hasApiKey,
    required this.hasMemory,
    required this.isLoadingLocalData,
    required this.error,
    required this.messages,
    required this.isBusy,
    required this.scrollController,
    required this.composer,
    required this.languageCode,
  });

  final String model;
  final bool hasApiKey;
  final bool hasMemory;
  final bool isLoadingLocalData;
  final String? error;
  final List<ChatMessage> messages;
  final bool isBusy;
  final ScrollController scrollController;
  final Widget composer;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ModelBar(
          model: model,
          hasApiKey: hasApiKey,
          hasMemory: hasMemory,
          isLoading: isLoadingLocalData,
          languageCode: languageCode,
        ),
        if (!hasApiKey)
          _StatusBanner(
            icon: Icons.key_off,
            text: t(languageCode, 'missingApiKey'),
          ),
        if (error != null)
          _StatusBanner(icon: Icons.warning_amber_rounded, text: error!),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
            itemCount: messages.length + (isBusy ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == messages.length) {
                return const _TypingBubble();
              }
              return _MessageBubble(message: messages[index]);
            },
          ),
        ),
        composer,
      ],
    );
  }
}

class _LibraryPage extends StatelessWidget {
  const _LibraryPage({
    required this.conversations,
    required this.currentConversationId,
    required this.localMemory,
    required this.languageCode,
    required this.onNewConversation,
    required this.onOpenConversation,
  });

  final List<ChatConversation> conversations;
  final String currentConversationId;
  final String localMemory;
  final String languageCode;
  final VoidCallback onNewConversation;
  final ValueChanged<String> onOpenConversation;

  @override
  Widget build(BuildContext context) {
    final sorted = List<ChatConversation>.of(conversations)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SectionHeader(
          title: t(languageCode, 'library'),
          action: FilledButton.icon(
            onPressed: onNewConversation,
            icon: const Icon(Icons.add_comment_outlined),
            label: Text(t(languageCode, 'newConversation')),
          ),
        ),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(languageCode, 'memoryPanel'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                localMemory.trim().isEmpty
                    ? t(languageCode, 'emptyMemory')
                    : localMemory,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          t(languageCode, 'recentChats'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...sorted.map(
          (conversation) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _HistoryTile(
              title: conversation.title,
              subtitle: conversation.subtitleFor(languageCode),
              icon: Icons.chat_bubble_outline,
              isSelected: conversation.id == currentConversationId,
              onTap: () => onOpenConversation(conversation.id),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolsPage extends StatelessWidget {
  const _ToolsPage({
    required this.languageCode,
    required this.enabled,
    required this.onToolSelected,
  });

  final String languageCode;
  final bool enabled;
  final ValueChanged<_ToolAction> onToolSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SectionHeader(title: t(languageCode, 'toolbox')),
        const SizedBox(height: 12),
        _ToolCard(
          icon: Icons.image_outlined,
          title: t(languageCode, 'generateImageShort'),
          description: t(languageCode, 'imageToolDesc'),
          enabled: enabled,
          onTap: () => onToolSelected(_ToolAction.image),
        ),
        _ToolCard(
          icon: Icons.description_outlined,
          title: t(languageCode, 'ocrFile'),
          description: t(languageCode, 'ocrToolDesc'),
          enabled: enabled,
          onTap: () => onToolSelected(_ToolAction.ocr),
        ),
        _ToolCard(
          icon: Icons.graphic_eq,
          title: t(languageCode, 'transcribeAudio'),
          description: t(languageCode, 'audioToolDesc'),
          enabled: enabled,
          onTap: () => onToolSelected(_ToolAction.audio),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        ?action,
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181A1F) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2D34) : const Color(0xFFE6E2DA),
        ),
      ),
      child: child,
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Panel(
        child: ListTile(
          enabled: enabled,
          onTap: enabled ? onTap : null,
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: enabled ? _coral : null),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(description),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _ModelBar extends StatelessWidget {
  const _ModelBar({
    required this.model,
    required this.hasApiKey,
    required this.hasMemory,
    required this.isLoading,
    required this.languageCode,
  });

  final String model;
  final bool hasApiKey;
  final bool hasMemory;
  final bool isLoading;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E2DA)),
          boxShadow: [
            BoxShadow(
              color: _ink.withAlpha(10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                icon: Icons.auto_awesome,
                label: model,
                color: _coral,
              ),
              _StatusPill(
                icon: hasApiKey ? Icons.key : Icons.key_off,
                label: hasApiKey
                    ? t(languageCode, 'localKey')
                    : t(languageCode, 'missingKeyShort'),
                color: hasApiKey ? _cyan : _coral,
              ),
              _StatusPill(
                icon: hasMemory ? Icons.psychology : Icons.memory,
                label: hasMemory
                    ? t(languageCode, 'localMemory')
                    : t(languageCode, 'emptyMemory'),
                color: hasMemory ? _amber : const Color(0xFF8E8378),
              ),
              if (isLoading)
                _StatusPill(
                  icon: Icons.sync,
                  label: t(languageCode, 'loading'),
                  color: const Color(0xFF8E8378),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  const _HistorySheet({
    required this.conversations,
    required this.currentConversationId,
    required this.languageCode,
  });

  final List<ChatConversation> conversations;
  final String currentConversationId;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final sorted = List<ChatConversation>.of(conversations)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                t(languageCode, 'history'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.56,
            child: ListView.separated(
              itemCount: sorted.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _HistoryTile(
                    title: t(languageCode, 'newConversation'),
                    subtitle: t(languageCode, 'startNewThread'),
                    icon: Icons.add_comment_outlined,
                    isSelected: false,
                    onTap: () => Navigator.of(context).pop('__new__'),
                  );
                }

                final conversation = sorted[index - 1];
                return _HistoryTile(
                  title: conversation.title,
                  subtitle: conversation.subtitleFor(languageCode),
                  icon: Icons.chat_bubble_outline,
                  isSelected: conversation.id == currentConversationId,
                  onTap: () => Navigator.of(context).pop(conversation.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: isSelected ? _coral.withAlpha(30) : _mist.withAlpha(120),
      leading: Icon(icon, color: isSelected ? _coral : _ink),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: _coral)
          : null,
    );
  }
}

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet({
    required this.apiKey,
    required this.model,
    required this.localMemory,
    required this.languageCode,
    required this.themeMode,
    required this.client,
  });

  final String apiKey;
  final String model;
  final String localMemory;
  final String languageCode;
  final ThemeMode themeMode;
  final MistralClient client;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _memoryController;
  late String _selectedModel;
  late String _selectedLanguageCode;
  late ThemeMode _selectedThemeMode;
  List<MistralModel> _models = const [];
  bool _isLoadingModels = false;
  String? _modelsError;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.apiKey);
    _memoryController = TextEditingController(text: widget.localMemory);
    _selectedModel = widget.model;
    _selectedLanguageCode = widget.languageCode;
    _selectedThemeMode = widget.themeMode;
    if (widget.apiKey.trim().isNotEmpty) {
      _loadModels();
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _memoryController.dispose();
    super.dispose();
  }

  Future<void> _loadModels() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty || _isLoadingModels) {
      setState(() {
        _modelsError = 'Ajoute une cle API avant de charger les modeles.';
      });
      return;
    }

    setState(() {
      _isLoadingModels = true;
      _modelsError = null;
    });

    try {
      final models = await widget.client.listModels(apiKey: apiKey);
      if (!mounted) {
        return;
      }
      setState(() {
        _models = models;
        if (models.isNotEmpty &&
            !models.any((model) => model.id == _selectedModel)) {
          _selectedModel = models.first.id;
        }
      });
    } on MistralException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _modelsError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _modelsError = 'Impossible de charger les modeles.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingModels = false;
        });
      }
    }
  }

  void _save() {
    final model = _selectedModel.trim().isEmpty
        ? _mistralModel
        : _selectedModel;

    Navigator.of(context).pop(
      SettingsResult(
        apiKey: _apiKeyController.text.trim(),
        model: model,
        localMemory: _memoryController.text.trim(),
        languageCode: _selectedLanguageCode,
        themeMode: _selectedThemeMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  t(_selectedLanguageCode, 'settings'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                labelText: t(_selectedLanguageCode, 'apiKey'),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureKey = !_obscureKey;
                    });
                  },
                  icon: Icon(
                    _obscureKey
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ApiKeyLink(languageCode: _selectedLanguageCode),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguageCode,
              decoration: InputDecoration(
                labelText: t(_selectedLanguageCode, 'language'),
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Francais')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'es', child: Text('Espanol')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedLanguageCode = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ThemeMode>(
              initialValue: _selectedThemeMode,
              decoration: InputDecoration(
                labelText: t(_selectedLanguageCode, 'theme'),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(t(_selectedLanguageCode, 'themeSystem')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(t(_selectedLanguageCode, 'themeLight')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(t(_selectedLanguageCode, 'themeDark')),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedThemeMode = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _ModelSelector(
              selectedModel: _selectedModel,
              models: _models,
              isLoading: _isLoadingModels,
              error: _modelsError,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedModel = value;
                });
              },
              onRefresh: _loadModels,
              languageCode: _selectedLanguageCode,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoadingModels ? null : _loadModels,
              icon: _isLoadingModels
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync_outlined),
              label: Text(
                _isLoadingModels
                    ? t(_selectedLanguageCode, 'loadingModels')
                    : t(_selectedLanguageCode, 'fetchModels'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memoryController,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: t(_selectedLanguageCode, 'memory'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(t(_selectedLanguageCode, 'save')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiKeyLink extends StatelessWidget {
  const _ApiKeyLink({required this.languageCode});

  final String languageCode;

  Future<void> _open() async {
    await launchUrl(_mistralApiKeysUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.open_in_new, size: 17, color: _coral),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t(languageCode, 'getApiKey'),
                      style: const TextStyle(
                        color: _coral,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                        decorationColor: _coral,
                      ),
                    ),
                    Text(
                      t(languageCode, 'getApiKeyHelp'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelSelector extends StatelessWidget {
  const _ModelSelector({
    required this.selectedModel,
    required this.models,
    required this.isLoading,
    required this.error,
    required this.onChanged,
    required this.onRefresh,
    required this.languageCode,
  });

  final String selectedModel;
  final List<MistralModel> models;
  final bool isLoading;
  final String? error;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRefresh;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final items = <MistralModel>[
      if (selectedModel.isNotEmpty &&
          !models.any((model) => model.id == selectedModel))
        MistralModel(id: selectedModel, name: selectedModel),
      ...models,
    ];

    if (items.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: t(languageCode, 'model'),
          border: const OutlineInputBorder(),
          errorText: error,
          suffixIcon: IconButton(
            onPressed: isLoading ? null : onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ),
        child: Text(
          isLoading
              ? t(languageCode, 'loading')
              : t(languageCode, 'loadModelsHint'),
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: selectedModel.isEmpty ? items.first.id : selectedModel,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: t(languageCode, 'model'),
        border: const OutlineInputBorder(),
        errorText: error,
      ),
      items: items.map((model) {
        return DropdownMenuItem(
          value: model.id,
          child: Text(model.displayName, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: isLoading ? null : onChanged,
    );
  }
}

class _ImagePromptSheet extends StatelessWidget {
  const _ImagePromptSheet({
    required this.controller,
    required this.languageCode,
  });

  final TextEditingController controller;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                t(languageCode, 'generateImage'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t(languageCode, 'imagePrompt'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              final prompt = controller.text.trim();
              Navigator.of(context).pop(prompt);
            },
            icon: const Icon(Icons.image_outlined),
            label: Text(t(languageCode, 'generate')),
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.enabled,
    required this.isSending,
    required this.isListening,
    required this.onSend,
    required this.onDictation,
    required this.onToolSelected,
    required this.languageCode,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isSending;
  final bool isListening;
  final VoidCallback onSend;
  final VoidCallback onDictation;
  final ValueChanged<_ToolAction> onToolSelected;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(226),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(230), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: _ink.withAlpha(28),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox.square(
              dimension: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _mist,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _cyan.withAlpha(58)),
                ),
                child: PopupMenuButton<_ToolAction>(
                  enabled: enabled,
                  tooltip: t(languageCode, 'tools'),
                  onSelected: onToolSelected,
                  icon: const Icon(Icons.add_rounded, color: _ink),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ToolAction.image,
                      child: ListTile(
                        leading: const Icon(Icons.image_outlined),
                        title: Text(t(languageCode, 'generateImageShort')),
                      ),
                    ),
                    PopupMenuItem(
                      value: _ToolAction.ocr,
                      child: ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(t(languageCode, 'ocrFile')),
                      ),
                    ),
                    PopupMenuItem(
                      value: _ToolAction.audio,
                      child: ListTile(
                        leading: const Icon(Icons.graphic_eq),
                        title: Text(t(languageCode, 'transcribeAudio')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: t(languageCode, 'message'),
                  filled: true,
                  fillColor: const Color(0xFFF3EFE4),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox.square(
              dimension: 52,
              child: IconButton.filledTonal(
                onPressed: enabled ? onDictation : null,
                style: IconButton.styleFrom(
                  backgroundColor: isListening ? _coral : _mist,
                  foregroundColor: isListening ? Colors.white : _ink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                tooltip: isListening
                    ? t(languageCode, 'stopDictation')
                    : t(languageCode, 'dictation'),
                icon: Icon(isListening ? Icons.mic : Icons.mic_none_rounded),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox.square(
              dimension: 52,
              child: FilledButton(
                onPressed: enabled ? onSend : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isSending
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final textColor = isUser ? Colors.white : _ink;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.82;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth.clamp(260, 720)),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: isUser
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_ink, Color(0xFF303244)],
                  )
                : null,
            color: isUser ? null : Colors.white.withAlpha(232),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 6),
              bottomRight: Radius.circular(isUser ? 6 : 20),
            ),
            border: isUser
                ? null
                : Border.all(color: Colors.white.withAlpha(210)),
            boxShadow: [
              BoxShadow(
                color: _ink.withAlpha(isUser ? 34 : 18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                    File(message.imagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  height: 1.42,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(232),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: Colors.white.withAlpha(210)),
          boxShadow: [
            BoxShadow(
              color: _ink.withAlpha(18),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulseDot(delay: 0),
            SizedBox(width: 5),
            _PulseDot(delay: 100),
            SizedBox(width: 5),
            _PulseDot(delay: 200),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.delay});

  final int delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.45, end: 1),
      duration: Duration(milliseconds: 650 + delay),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: scheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}

class MistralClient {
  MistralClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static final Uri _endpoint = Uri.parse(
    'https://api.mistral.ai/v1/chat/completions',
  );
  static final Uri _modelsEndpoint = Uri.parse(
    'https://api.mistral.ai/v1/models',
  );
  static final Uri _conversationsEndpoint = Uri.parse(
    'https://api.mistral.ai/v1/conversations',
  );
  static final Uri _filesEndpoint = Uri.parse(
    'https://api.mistral.ai/v1/files',
  );
  static final Uri _ocrEndpoint = Uri.parse('https://api.mistral.ai/v1/ocr');
  static final Uri _transcriptionsEndpoint = Uri.parse(
    'https://api.mistral.ai/v1/audio/transcriptions',
  );

  final http.Client _httpClient;

  Future<List<MistralModel>> listModels({required String apiKey}) async {
    if (apiKey.trim().isEmpty) {
      throw const MistralException('Cle API Mistral manquante.');
    }

    final response = await _httpClient.get(
      _modelsEndpoint,
      headers: {
        'Authorization': 'Bearer ${apiKey.trim()}',
        'Accept': 'application/json',
      },
    );
    final decoded = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MistralException(
        decoded is Map<String, dynamic>
            ? _extractApiError(decoded)
            : 'Erreur Mistral ${response.statusCode}.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const MistralException('Liste des modeles invalide.');
    }

    final data = decoded['data'];
    if (data is! List) {
      throw const MistralException('Aucun modele disponible.');
    }

    final models =
        data
            .whereType<Map<String, dynamic>>()
            .map(MistralModel.fromJson)
            .where((model) => _isLikelyChatModel(model.id))
            .toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));

    if (models.isEmpty) {
      throw const MistralException('Aucun modele de chat trouve.');
    }
    return models;
  }

  Future<String> complete({
    required String apiKey,
    required String model,
    required String localMemory,
    required List<ChatMessage> messages,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const MistralException('Cle API Mistral manquante.');
    }

    final response = await _httpClient.post(
      _endpoint,
      headers: {
        'Authorization': 'Bearer ${apiKey.trim()}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': _buildApiMessages(localMemory, messages),
      }),
    );

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? _extractApiError(decoded)
          : 'Erreur Mistral ${response.statusCode}.';
      throw MistralException(message);
    }

    if (decoded is! Map<String, dynamic>) {
      throw const MistralException('Reponse Mistral invalide.');
    }

    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw const MistralException('Reponse Mistral vide.');
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      throw const MistralException('Format de choix invalide.');
    }

    final message = firstChoice['message'];
    if (message is! Map<String, dynamic>) {
      throw const MistralException('Message Mistral invalide.');
    }

    final content = _contentAsText(message['content']);
    if (content.isEmpty) {
      throw const MistralException('Reponse Mistral sans texte.');
    }
    return content;
  }

  Future<String> updateMemory({
    required String apiKey,
    required String model,
    required String currentMemory,
    required List<ChatMessage> messages,
  }) async {
    final recentMessages = messages.reversed
        .take(10)
        .toList()
        .reversed
        .map((message) => '${message.role.apiName}: ${message.content}')
        .join('\n');

    if (recentMessages.trim().isEmpty) {
      return currentMemory;
    }

    final response = await _httpClient.post(
      _endpoint,
      headers: {
        'Authorization': 'Bearer ${apiKey.trim()}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'temperature': 0,
        'messages': [
          {
            'role': 'system',
            'content':
                'Tu mets a jour une memoire personnelle locale pour un assistant. Garde uniquement les informations stables et utiles sur l utilisateur: preferences, projets, contraintes, style souhaite, faits durables. Supprime les details temporaires. Retourne uniquement la nouvelle memoire, en phrases courtes. Si rien ne merite d etre retenu, retourne exactement la memoire actuelle.',
          },
          {
            'role': 'user',
            'content':
                'Memoire actuelle:\n${currentMemory.trim().isEmpty ? "(vide)" : currentMemory.trim()}\n\nConversation recente:\n$recentMessages',
          },
        ],
      }),
    );

    final decoded = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MistralException(
        decoded is Map<String, dynamic>
            ? _extractApiError(decoded)
            : 'Erreur Mistral ${response.statusCode}.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      return currentMemory;
    }

    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      return currentMemory;
    }
    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      return currentMemory;
    }
    final message = firstChoice['message'];
    if (message is! Map<String, dynamic>) {
      return currentMemory;
    }

    final content = _contentAsText(message['content']).trim();
    if (content.isEmpty || content == '(vide)') {
      return '';
    }
    return content;
  }

  Future<GeneratedImage> generateImage({
    required String apiKey,
    required String model,
    required String prompt,
  }) async {
    final decoded = await _postJson(
      apiKey: apiKey,
      url: _conversationsEndpoint,
      body: {
        'model': model,
        'store': false,
        'instructions':
            'Use the image generation tool when the user asks for an image.',
        'tools': [
          {'type': 'image_generation'},
        ],
        'inputs': prompt,
      },
    );

    final fileId = _findFirstString(decoded, 'file_id');
    if (fileId == null || fileId.isEmpty) {
      throw const MistralException('Aucune image generee par Mistral.');
    }

    return GeneratedImage(
      bytes: await downloadFile(apiKey: apiKey, fileId: fileId),
      text: _collectResponseText(decoded),
      fileId: fileId,
    );
  }

  Future<String> ocrFile({
    required String apiKey,
    required String path,
    required String fileName,
  }) async {
    final fileId = await uploadFile(
      apiKey: apiKey,
      path: path,
      fileName: fileName,
      purpose: 'ocr',
    );
    final decoded = await _postJson(
      apiKey: apiKey,
      url: _ocrEndpoint,
      body: {
        'model': 'mistral-ocr-latest',
        'document': {'file_id': fileId},
        'table_format': 'markdown',
      },
    );

    return _extractOcrMarkdown(decoded);
  }

  Future<String> transcribeAudio({
    required String apiKey,
    required String path,
    required String fileName,
  }) async {
    final request = http.MultipartRequest('POST', _transcriptionsEndpoint)
      ..headers['Authorization'] = 'Bearer ${apiKey.trim()}'
      ..fields['model'] = 'voxtral-mini-latest'
      ..fields['diarize'] = 'false'
      ..files.add(
        await http.MultipartFile.fromPath('file', path, filename: fileName),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final decoded = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MistralException(
        decoded is Map<String, dynamic>
            ? _extractApiError(decoded)
            : 'Erreur Mistral ${response.statusCode}.',
      );
    }
    if (decoded is Map<String, dynamic>) {
      final text = decoded['text'];
      if (text is String) {
        return text.trim();
      }
    }
    throw const MistralException('Transcription Voxtral invalide.');
  }

  Future<String> uploadFile({
    required String apiKey,
    required String path,
    required String fileName,
    required String purpose,
  }) async {
    final request = http.MultipartRequest('POST', _filesEndpoint)
      ..headers['Authorization'] = 'Bearer ${apiKey.trim()}'
      ..fields['purpose'] = purpose
      ..fields['visibility'] = 'user'
      ..files.add(
        await http.MultipartFile.fromPath('file', path, filename: fileName),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final decoded = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MistralException(
        decoded is Map<String, dynamic>
            ? _extractApiError(decoded)
            : 'Erreur Mistral ${response.statusCode}.',
      );
    }
    if (decoded is Map<String, dynamic>) {
      final id = decoded['id'];
      if (id is String && id.isNotEmpty) {
        return id;
      }
    }
    throw const MistralException('Upload fichier invalide.');
  }

  bool _isLikelyChatModel(String id) {
    final normalized = id.toLowerCase();
    const blocked = [
      'embed',
      'ocr',
      'moderation',
      'voxtral',
      'tts',
      'transcribe',
    ];
    return !blocked.any(normalized.contains);
  }

  Future<List<int>> downloadFile({
    required String apiKey,
    required String fileId,
  }) async {
    final response = await _httpClient.get(
      Uri.parse('https://api.mistral.ai/v1/files/$fileId/content'),
      headers: {'Authorization': 'Bearer ${apiKey.trim()}'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MistralException(
        'Telechargement image impossible (${response.statusCode}).',
      );
    }
    return response.bodyBytes;
  }

  Future<Object?> _postJson({
    required String apiKey,
    required Uri url,
    required Map<String, Object?> body,
  }) async {
    final response = await _httpClient.post(
      url,
      headers: {
        'Authorization': 'Bearer ${apiKey.trim()}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
    final decoded = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MistralException(
        decoded is Map<String, dynamic>
            ? _extractApiError(decoded)
            : 'Erreur Mistral ${response.statusCode}.',
      );
    }
    return decoded;
  }

  Object? _decodeResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (body.trim().isEmpty) {
      return null;
    }
    return jsonDecode(body);
  }

  List<Map<String, String>> _buildApiMessages(
    String localMemory,
    List<ChatMessage> messages,
  ) {
    final apiMessages = <Map<String, String>>[];
    final memory = localMemory.trim();
    if (memory.isNotEmpty) {
      apiMessages.add({
        'role': ChatRole.system.apiName,
        'content':
            'Memoire locale de l utilisateur. Utilise ces informations comme contexte, sans les reveler directement sauf demande explicite.\n$memory',
      });
    }

    apiMessages.addAll(
      messages.map(
        (message) => {'role': message.role.apiName, 'content': message.content},
      ),
    );

    return apiMessages;
  }

  String _extractOcrMarkdown(Object? decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw const MistralException('Reponse OCR invalide.');
    }
    final pages = decoded['pages'];
    if (pages is! List) {
      return '';
    }
    return pages
        .whereType<Map<String, dynamic>>()
        .map((page) {
          final index = page['index'];
          final markdown = page['markdown'];
          if (markdown is! String || markdown.trim().isEmpty) {
            return '';
          }
          return 'Page $index\n\n${markdown.trim()}';
        })
        .where((page) => page.isNotEmpty)
        .join('\n\n---\n\n');
  }

  String? _findFirstString(Object? value, String key) {
    if (value is Map<String, dynamic>) {
      final direct = value[key];
      if (direct is String && direct.isNotEmpty) {
        return direct;
      }
      for (final child in value.values) {
        final result = _findFirstString(child, key);
        if (result != null) {
          return result;
        }
      }
    }

    if (value is List) {
      for (final child in value) {
        final result = _findFirstString(child, key);
        if (result != null) {
          return result;
        }
      }
    }

    return null;
  }

  String _collectResponseText(Object? value) {
    final parts = <String>[];
    void visit(Object? current) {
      if (current is Map<String, dynamic>) {
        final type = current['type'];
        final text = current['text'];
        if (type == 'text' && text is String && text.trim().isNotEmpty) {
          parts.add(text.trim());
        }
        for (final child in current.values) {
          visit(child);
        }
      } else if (current is List) {
        for (final child in current) {
          visit(child);
        }
      }
    }

    visit(value);
    return parts.join('\n').trim();
  }

  String _extractApiError(Map<String, dynamic> decoded) {
    final detail = decoded['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }

    final message = decoded['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final error = decoded['error'];
    if (error is Map<String, dynamic>) {
      final errorMessage = error['message'];
      if (errorMessage is String && errorMessage.trim().isNotEmpty) {
        return errorMessage;
      }
    }

    return 'Erreur Mistral.';
  }

  String _contentAsText(Object? content) {
    if (content is String) {
      return content.trim();
    }

    if (content is List) {
      return content
          .map((chunk) {
            if (chunk is Map<String, dynamic>) {
              return chunk['text'] ?? '';
            }
            return '';
          })
          .join()
          .trim();
    }

    return '';
  }
}

abstract class AppStorage {
  Future<String> loadApiKey();
  Future<void> saveApiKey(String value);
  Future<String> loadModel();
  Future<void> saveModel(String value);
  Future<String> loadLocalMemory();
  Future<void> saveLocalMemory(String value);
  Future<String> loadLanguageCode();
  Future<void> saveLanguageCode(String value);
  Future<String> loadThemeMode();
  Future<void> saveThemeMode(String value);
  Future<List<ChatMessage>> loadMessages();
  Future<void> saveMessages(List<ChatMessage> messages);
  Future<List<ChatConversation>> loadConversations();
  Future<void> saveConversations(List<ChatConversation> conversations);
  Future<String> loadCurrentConversationId();
  Future<void> saveCurrentConversationId(String value);
  Future<void> clearAll();
}

class DeviceAppStorage implements AppStorage {
  const DeviceAppStorage();

  static const _secureStorage = FlutterSecureStorage();
  static const _apiKeyKey = 'mistral_api_key';
  static const _modelKey = 'mistral_model';
  static const _memoryKey = 'local_memory';
  static const _languageKey = 'language_code';
  static const _themeModeKey = 'theme_mode';
  static const _messagesKey = 'chat_messages';
  static const _conversationsKey = 'chat_conversations';
  static const _currentConversationKey = 'current_conversation_id';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String> loadApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey) ?? '';
  }

  @override
  Future<void> saveApiKey(String value) async {
    if (value.trim().isEmpty) {
      await _secureStorage.delete(key: _apiKeyKey);
      return;
    }
    await _secureStorage.write(key: _apiKeyKey, value: value.trim());
  }

  @override
  Future<String> loadModel() async {
    return (await _prefs).getString(_modelKey) ?? '';
  }

  @override
  Future<void> saveModel(String value) async {
    await (await _prefs).setString(_modelKey, value.trim());
  }

  @override
  Future<String> loadLocalMemory() async {
    return (await _prefs).getString(_memoryKey) ?? '';
  }

  @override
  Future<void> saveLocalMemory(String value) async {
    await (await _prefs).setString(_memoryKey, value.trim());
  }

  @override
  Future<String> loadLanguageCode() async {
    return (await _prefs).getString(_languageKey) ?? '';
  }

  @override
  Future<void> saveLanguageCode(String value) async {
    await (await _prefs).setString(_languageKey, value);
  }

  @override
  Future<String> loadThemeMode() async {
    return (await _prefs).getString(_themeModeKey) ?? '';
  }

  @override
  Future<void> saveThemeMode(String value) async {
    await (await _prefs).setString(_themeModeKey, value);
  }

  @override
  Future<List<ChatMessage>> loadMessages() async {
    final raw = (await _prefs).getString(_messagesKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveMessages(List<ChatMessage> messages) async {
    final encoded = jsonEncode(
      messages.map((message) => message.toJson()).toList(),
    );
    await (await _prefs).setString(_messagesKey, encoded);
  }

  @override
  Future<List<ChatConversation>> loadConversations() async {
    final raw = (await _prefs).getString(_conversationsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ChatConversation.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveConversations(List<ChatConversation> conversations) async {
    final encoded = jsonEncode(
      conversations.map((conversation) => conversation.toJson()).toList(),
    );
    await (await _prefs).setString(_conversationsKey, encoded);
  }

  @override
  Future<String> loadCurrentConversationId() async {
    return (await _prefs).getString(_currentConversationKey) ?? '';
  }

  @override
  Future<void> saveCurrentConversationId(String value) async {
    await (await _prefs).setString(_currentConversationKey, value);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await _secureStorage.delete(key: _apiKeyKey);
    await prefs.remove(_modelKey);
    await prefs.remove(_memoryKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_themeModeKey);
    await prefs.remove(_messagesKey);
    await prefs.remove(_conversationsKey);
    await prefs.remove(_currentConversationKey);
  }
}

class MemoryAppStorage implements AppStorage {
  String apiKey = '';
  String model = '';
  String localMemory = '';
  String languageCode = '';
  String themeMode = '';
  List<ChatMessage> messages = const [];
  List<ChatConversation> conversations = const [];
  String currentConversationId = '';

  @override
  Future<String> loadApiKey() async => apiKey;

  @override
  Future<void> saveApiKey(String value) async {
    apiKey = value;
  }

  @override
  Future<String> loadModel() async => model;

  @override
  Future<void> saveModel(String value) async {
    model = value;
  }

  @override
  Future<String> loadLocalMemory() async => localMemory;

  @override
  Future<void> saveLocalMemory(String value) async {
    localMemory = value;
  }

  @override
  Future<String> loadLanguageCode() async => languageCode;

  @override
  Future<void> saveLanguageCode(String value) async {
    languageCode = value;
  }

  @override
  Future<String> loadThemeMode() async => themeMode;

  @override
  Future<void> saveThemeMode(String value) async {
    themeMode = value;
  }

  @override
  Future<List<ChatMessage>> loadMessages() async => List.of(messages);

  @override
  Future<void> saveMessages(List<ChatMessage> messages) async {
    this.messages = List.of(messages);
  }

  @override
  Future<List<ChatConversation>> loadConversations() async {
    return List.of(conversations);
  }

  @override
  Future<void> saveConversations(List<ChatConversation> conversations) async {
    this.conversations = List.of(conversations);
  }

  @override
  Future<String> loadCurrentConversationId() async => currentConversationId;

  @override
  Future<void> saveCurrentConversationId(String value) async {
    currentConversationId = value;
  }

  @override
  Future<void> clearAll() async {
    apiKey = '';
    model = '';
    localMemory = '';
    languageCode = '';
    themeMode = '';
    messages = const [];
    conversations = const [];
    currentConversationId = '';
  }
}

class SettingsResult {
  const SettingsResult({
    required this.apiKey,
    required this.model,
    required this.localMemory,
    required this.languageCode,
    required this.themeMode,
  });

  final String apiKey;
  final String model;
  final String localMemory;
  final String languageCode;
  final ThemeMode themeMode;
}

class GeneratedImage {
  const GeneratedImage({
    required this.bytes,
    required this.text,
    required this.fileId,
  });

  final List<int> bytes;
  final String text;
  final String fileId;
}

class MistralModel {
  const MistralModel({required this.id, required this.name});

  factory MistralModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final name = json['name'] as String? ?? id;
    return MistralModel(id: id, name: name.isEmpty ? id : name);
  }

  final String id;
  final String name;

  String get displayName {
    if (name == id) {
      return id;
    }
    return '$name  ($id)';
  }
}

class MistralException implements Exception {
  const MistralException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    this.imagePath,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: ChatRole.fromApiName(json['role'] as String? ?? 'assistant'),
      content: json['content'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
    );
  }

  final ChatRole role;
  final String content;
  final String? imagePath;

  Map<String, String> toJson() {
    final json = {'role': role.apiName, 'content': content};
    final imagePath = this.imagePath;
    if (imagePath != null) {
      json['imagePath'] = imagePath;
    }
    return json;
  }
}

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.messages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    return ChatConversation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Conversation',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      messages: rawMessages is List
          ? rawMessages
                .whereType<Map<String, dynamic>>()
                .map(ChatMessage.fromJson)
                .toList()
          : const [],
    );
  }

  final String id;
  final String title;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  String subtitleFor(String languageCode) {
    final count = messages.length;
    if (count == 0) {
      return t(languageCode, 'noMessages');
    }
    return '$count messages';
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}

enum ChatRole {
  system('system'),
  user('user'),
  assistant('assistant');

  const ChatRole(this.apiName);

  final String apiName;

  static ChatRole fromApiName(String apiName) {
    return ChatRole.values.firstWhere(
      (role) => role.apiName == apiName,
      orElse: () => ChatRole.assistant,
    );
  }
}

enum _LocalAction { clearAll }

enum _ToolAction { image, ocr, audio }

enum _AppSection { chat, library, tools }
