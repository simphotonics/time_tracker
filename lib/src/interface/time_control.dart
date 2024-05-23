abstract interface class TimeControl {
  /// Starts the objects time line. Records the first time point.
  void start();

  /// Pauses the objects time line. Adds a time point
  /// indicating the start of a pause.
  void pause();

  /// Resumes a paused object. Adds a time point,
  /// indicating the end of a pause.
  void resume();

  /// Ends the objects time line. Records the last time point.
  void end();
}
