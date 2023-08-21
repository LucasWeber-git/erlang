### Water Simulation
Little project made for a college work :D

It creates a simulation where particles of Oxygen and Hydrogen are randomly generated between a specific interval of seconds and then are combined into molecules of water. Also, a particle can only be combined when it's energized, which takes a random amount of seconds to occur.

### How to run
On a proper Erlang environment, run the following commands:

```erlang
% Open project's location
cd("C:/Example/erlang/water_simulation").

% Compile the project
c(water_simulation).

% Run start/1 method, informing the number of seconds between each particle is created
water_simulation:start(10).
```