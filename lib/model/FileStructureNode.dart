class FileStructureNode {
  final String name;
  final List<FileStructureNode> children;

  FileStructureNode({required this.name, required this.children});
}