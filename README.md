# pipex

Experimental Elixir + GenStage project that explores its capabilities for async data processing.

## How to

Basically this process brings up three processes:

* Producer: buffer for incoming events
* Consumer: consumes one event whenever processing is done
* Processor: processes the event

You can send an event - ideally of String type for better logging - using `Pipeline.add_event/1`.
