# Single-thread PSC networking refactor

The PSC TCP socket is now owned entirely by `psc_run()` in `listener.c`.

There is no `handle_client` thread and no socket mutex.  The same thread:

- accepts/replaces the one IOC connection,
- receives IOC messages,
- sends all normal PSC traffic,
- handles disconnect/close,
- calls the periodic data scheduler (`pscdata_poll`).

Periodic data behavior:

- `sadata_send()` every 100 ms,
- `snapshot_process()` every 100 ms,
- `lstats_send()` every 500 ms,
- `bpc_send()` every 500 ms when bipolar mode is enabled.

`pscdata.c` does not create a FreeRTOS task; it is called by `psc_run()`.

The IOC 1 Hz heartbeat is retained.  No received IOC message for 5 seconds
causes the client socket to be closed so the IOC can reconnect.

A new IOC connection always supersedes any existing client connection.

`psc_recvmsg()` now returns `EMSGSIZE` for an oversized message instead of
trying to drain the remainder of a potentially corrupt length field.
