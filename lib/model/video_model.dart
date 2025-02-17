enum VideoSource { remote, asset }

class VideoModel {
  final String path;
  final VideoSource source;

  VideoModel(this.path, this.source);
}
