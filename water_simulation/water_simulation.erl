-module(water_simulation).
-export([start/1, particle_generator/3, particle/2, hydrogen_list/1, get_hydrogen_list/1, oxygen_list/1, get_oxygen_list/1, molecule_generator/2]).

%cria os processos e inicia o gerador
start(Seconds) -> 
    HydrogenListPid = spawn(water_simulation, hydrogen_list, [[]]),
    OxygenListPid = spawn(water_simulation, oxygen_list, [[]]),
    erlang:display("HydrogenListPid: " ++ pid_to_list(HydrogenListPid) ++ ", OxygenListPid: " ++ pid_to_list(OxygenListPid)),
    spawn(water_simulation, particle_generator, [Seconds, HydrogenListPid, OxygenListPid]),
    spawn(water_simulation, molecule_generator, [HydrogenListPid, OxygenListPid]).

% fica gerando particulas pra sempre
particle_generator(Seconds, HydrogenListPid, OxygenListPid) ->
    generate(HydrogenListPid, OxygenListPid),
    timer:sleep(Seconds * 1000),
    particle_generator(Seconds, HydrogenListPid, OxygenListPid).

% gera uma nova molecula já passando qual lista ela tem que ficar
generate(HydrogenListPid, OxygenListPid) -> 
    Elements = [{hydrogen, HydrogenListPid}, {oxygen, OxygenListPid}],
    RandomIndex = rand:uniform(length(Elements)),
    RandomElement = lists:nth(RandomIndex, Elements),
    spawn(water_simulation, particle, [element(1, RandomElement), element(2, RandomElement)]).

% energiza a molecula e depois adiciona na lista
particle(Element, ListPid) -> 
    erlang:display("New " ++ atom_to_list(Element) ++ " particle created with PID: " ++ pid_to_list(self())),
    RandomSeconds = rand:uniform(5), %TODO: mudar para rand:uniform(20) + 10
    timer:sleep(RandomSeconds * 1000),
    erlang:display(atom_to_list(Element) ++ " particle is energized, PID: " ++ pid_to_list(self())),
    ListPid ! {self(), add}.

% cria a lista e fica recebendo os Pids
hydrogen_list(List) ->
    receive
        {Pid, get_hydrogen_list} ->
            Pid ! {self(), List},
            hydrogen_list(List);
        {Pid, add} ->
            NewList = List ++ [Pid],
            erlang:display("-------"),
            erlang:display("hydrogen_list:"),
            erlang:display(NewList),
            erlang:display("-------"),
            hydrogen_list(NewList);
        {Pid, remove} ->
            hydrogen_list(lists:delete(Pid, List))
    end.

get_hydrogen_list(HydrogenListPid) ->
    HydrogenListPid ! {self(), get_hydrogen_list},
    receive
        {HydrogenListPid, HydrogenList} -> HydrogenList
    end.

% cria a lista e fica recebendo os Pids
oxygen_list(List) -> 
     receive
        {Pid, get_oxygen_list} ->
            Pid ! {self(), List},
            oxygen_list(List);
        {Pid, add} ->
            NewList = List ++ [Pid],
            erlang:display("-------"),
            erlang:display("oxygen_list:"),
            erlang:display(NewList),
            erlang:display("-------"),
            oxygen_list(NewList);
        {Pid, remove} ->
            oxygen_list(lists:delete(Pid, List))
    end.

get_oxygen_list(OxygenListPid) ->
    OxygenListPid ! {self(), get_oxygen_list},
    receive
        {OxygenListPid, OxygenList} -> OxygenList
    end.

% pega 2H e 1O e combina; fica buscando de tempos em tempos
molecule_generator(HydrogenListPid, OxygenListPid) ->
    HydrogenList = get_hydrogen_list(HydrogenListPid),
    OxygenList = get_oxygen_list(OxygenListPid),

    case {length(HydrogenList), length(OxygenList)} of
    {H, O} when H >= 2, O >= 1 ->
        PidH1 = lists:nth(length(HydrogenList), HydrogenList),
        PidH2 = lists:nth(length(HydrogenList)-1, HydrogenList),
        PidO = lists:nth(length(OxygenList), OxygenList),

        HydrogenListPid ! {PidH1, remove},
        HydrogenListPid ! {PidH2, remove},
        OxygenListPid ! {PidO, remove},
        
        erlang:display("Water molecule formed with: " ++
            pid_to_list(PidH1) ++ ", " ++ 
            pid_to_list(PidH2) ++ ", " ++
            pid_to_list(PidO)),

        timer:sleep(1000),
        molecule_generator(HydrogenListPid, OxygenListPid);
    _ ->
        timer:sleep(1000),
        molecule_generator(HydrogenListPid, OxygenListPid)
end.
