%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Servidor em prolog

% Módulos:
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/json)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_dirindex)).
%DEBUG:
:- use_module(library(http/http_error)).
:- debug.

% GET
:- http_handler(
    root(action), % Alias /action
    action,       % Predicado 'action'
    []).

:- http_handler(root(.), http_reply_from_files('.', []), [prefix]).

:- json_object
    controles(forward:integer, reverse: integer, left:integer, right:integer).

start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).

stop_server(Port) :-
    http_stop_server(Port, []).

action(Request) :-
    http_parameters(Request,
                    % sensores do carro:
                    [ x(X, [float]),
                      y(Y, [float]),
                      angle(ANGLE, [float]),
                      s1(S1, [float]),
                      s2(S2, [float]),
                      s3(S3, [float]),
                      s4(S4, [float]),
                      s5(S5, [float])
                    ]),
    SENSORES = [X,Y,ANGLE,S1,S2,S3,S4,S5],
    obter_controles(SENSORES, CONTROLES),
    CONTROLES = [FORWARD, REVERSE, LEFT, RIGHT],
    prolog_to_json( controles(FORWARD, REVERSE, LEFT, RIGHT), JOut ),
    reply_json( JOut ).

start :- format('~n~n--========================================--~n~n'),
         start_server(8080),
         format('~n~n--========================================--~n~n').
:- initialization start.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5], [F,Re,L,Ri]) :- 
    calcula_sensores([X,Y,ANGLE,S1,S2,S3,S4,S5], [F,Re,L,Ri]).

calcula_sensores([X,Y,ANGLE,S1,S2,S3,S4,S5], [F,Re,L,Ri]) :-
    Distancia_angulo is abs(ANGLE/(pi*2) - (pi*2)),
    % Distancia_angulo < abs((pi/2)/(pi*2) - (pi*2)),
    % Distancia_angulo > abs((pi*3/2)/(pi*2) - (pi*2)),
    avalia_sensor_esquerda(S1,S2, Sensores_esquerda),
    avalia_sensor_direita(S4,S5, Sensores_direita),
    avalia_sensor_frente(S2,S3,S4, Sensores_frente),
    calcula_acoes(Sensores_frente, Sensores_esquerda, Sensores_direita, [F,Re,L,Ri]).

calcula_acoes(Sensores_frente, Sensores_esquerda, Sensores_direita, [F,Re,L,Ri]) :-
    Frente is Sensores_frente + Sensores_esquerda + Sensores_direita,
    Esquerda is Sensores_frente + Sensores_esquerda - Sensores_direita,
    Direita is Sensores_frente - Sensores_esquerda + Sensores_direita,
    busca_melhor_acao(Frente, Esquerda, Direita, [F,Re,L,Ri]).

busca_melhor_acao(Frente, Esquerda, Direita, [1,0,0,0]) :-
    Frente =< Esquerda,
    Frente =< Direita.

busca_melhor_acao(Frente, Esquerda, Direita, [1,0,1,0]) :-
    Esquerda =< Frente,
    Esquerda =< Direita.

busca_melhor_acao(Frente, Esquerda, Direita, [1,0,0,1]) :-
    Direita =< Frente,
    Direita =< Esquerda.

avalia_sensor_esquerda(S1,S2, Media) :-
    Media is (S1 + S2)/2,
    Media >= 0.6.

avalia_sensor_esquerda(S1,S2, 0) :-
    Media is (S1 + S2)/2,
    Media < 0.6.

avalia_sensor_direita(S4,S5, Media) :-
    Media is (S4 + S5)/2,
    Media >= 0.6.

avalia_sensor_direita(S4,S5, 0) :-
    Media is (S4 + S5)/2,
    Media < 0.6.

avalia_sensor_frente(S2, S3, S4, Media) :-
    Media is (S2 + S3 +S4)/3.


% base
% menorElemDaLista([H|T], Index) :- 
%     menorElemDaLista([H|T], Index, H, MenorIndex, 1).
% 
% menorElemDaLista([], MenorIndex, _, MenorIndex, _).
% 
% menorElemDaLista([H|T], Index, Menor, MenorIndex, Count) :-
%     H < Menor,
%     Aux1 is H,
%     Aux2 is Count + 1,
%     menorElemDaLista(T, Index, Aux1, Count, Aux2). 
% 
% menorElemDaLista([_|T], Index, Menor, MenorIndex, Count) :-
%     Aux1 is Count + 1,
%     menorElemDaLista(T, Index, Menor, MenorIndex, Aux1). 
% 
% 
% 
% reverse_left([X,Y,ANGLE,S1,S2,S3,S4,S5], [0,1,1,0]).
% 
% reverse_right([X,Y,ANGLE,S1,S2,S3,S4,S5], [0,1,0,1]).
% 
% distanciaPontos(X1, Y1, X2, Y2, Distancia):- 
%     Distancia is sqrt((X1-X2*X1-X2)+(Y1-Y2*Y1-Y2)).


% evalute_state([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,0]) :- 
%     ANGLE / pi*2 =:= 0,
%     S1 >= 0, S1 =< 0.4,
%     S2 >= 0, S2 =< 0.4,
%     S3 >= 0, S3 =< 0.4,
%     S4 >= 0, S4 =< 0.4,
%     S5 >= 0, S5 =< 0.4.
% 
% evalute_state([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,1]) :-
%     ANGLE / pi*2 =:= 0,
%     S3 >= 0, S3 =< 0.6,
%     S1 > 0.6,
%     S2 > 0.6, 
%     S4 >= 0, S4 =< 0.6,
%     S5 >= 0, S5 =< 0.6,
% 
% evalute_state([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,1,0]) :-
%     ANGLE / pi*2 =:= 0,
%     S3 >= 0, S3 =< 0.6,
%     S4 > 0.6, 
%     S5 > 0.6,
%     S1 >= 0, S1 =< 0.6,
%     S2 >= 0, S2 =< 0.6,
% 
% evalute_state([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,0]) :-
%     ANGLE / pi*2 >= 0, ANGLE / pi*2 =< (pi*2) + (pi/4),
%     S3 > 0.6,
%     S1 > 0.6, 
%     S2 > 0.6,
%     S4 >= 0, S4 =< 0.6,
%     S5 >= 0, S5 =< 0.6,
% 
% evalute_state([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,0]) :-
%     ANGLE / pi*2 >= 0, ANGLE / pi*2 =< (pi*2) + (pi/4),
%     S3 > 0.6,
%     S4 > 0.6, 
%     S5 > 0.6,
%     S1 >= 0, S1 =< 0.6,
%     S2 >= 0, S2 =< 0.6,
% 
% 