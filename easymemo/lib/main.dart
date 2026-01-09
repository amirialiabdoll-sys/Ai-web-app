import 'package:intl/intl.dart';
import '../models/folder_model.dart';
import '../models/memo_model.dart';
import '../services/database_service.dart';
import 'memo_screen.dart';

class FolderScreen extends StatefulWidget {
  final FolderModel folder;

  const FolderScreen({super.key, required this.folder});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<MemoModel> _memos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    setState(() => _isLoading = true);
    final memos = await DatabaseService.instance.getMemosByFolder(widget.folder.id!);
    setState(() {
      _memos = memos;
      _isLoading = false;
    });
  }

  Future<void> _createMemo() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoScreen(folderId: widget.folder.id!),
      ),
    );
    _loadMemos();
  }

  Future<void> _deleteMemo(MemoModel memo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Memo'),
        content: Text('Are you sure you want to delete "${memo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteMemo(memo.id!);
      _loadMemos();
    }
  }

  Future<void> _setReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.folder.reminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(widget.folder.reminderTime ?? DateTime.now()),
      );

      if (time != null) {
        final reminderTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        final updatedFolder = FolderModel(
          id: widget.folder.id,
          name: widget.folder.name,
          createdAt: widget.folder.createdAt,
          reminderTime: reminderTime,
          color: widget.folder.color,
        );

        await DatabaseService.instance.updateFolder(updatedFolder);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder set for ${DateFormat('MMM dd, yyyy HH:mm').format(reminderTime)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm),
            onPressed: _setReminder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_add, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No memos yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to create your first memo',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMemos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _memos.length,
                    itemBuilder: (context, index) {
                      final memo = _memos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: memo.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(memo.imagePath!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.description),
                                ),
                          title: Text(
                            memo.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                memo.content.length > 50
                                    ? '${memo.content.substring(0, 50)}...'
                                    : memo.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Updated: ${DateFormat('MMM dd, yyyy').format(memo.updatedAt)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMemo(memo),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemoScreen(
                                  folderId: widget.folder.id!,
                                  memo: memo,
                                ),
                              ),
                            );
                            _loadMemos();
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMemo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
