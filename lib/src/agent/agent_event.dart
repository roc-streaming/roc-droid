/// Asynchronous event from Agent.
enum AgentEvent {
  // Audio device I/O failure.
  deviceError,

  // Network I/O failure.
  networkError,

  // Sender or receiver started or stopped.
  stateChanged,
}
