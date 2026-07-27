enum VideoSource { remote, local, asset }

class VideoModel {
  final String path;
  final VideoSource source;

  VideoModel(this.path, this.source);
}
