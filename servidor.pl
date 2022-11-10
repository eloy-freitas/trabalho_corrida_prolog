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
    direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [F,Re,L,Ri]).

distanciaPontos(X1, Y1, X2, Y2, Distancia):- 
    Distancia is sqrt((X1-X2*X1-X2)+(Y1-Y2*Y1-Y2)).

direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,0]) :-
    Centro is S2 + S3 + S4,
    Centro =< 0.6.

direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,1]) :-
    Esquerda is S1 + S2 + S3,
    Direita is S3 + S4 + S5,
    Esquerda > Direita.

direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,1,0]) :-
    Esquerda is S1 + S2 + S3,
    Direita is S3 + S4 + S5,
    Esquerda < Direita.

direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [0,1,0,0]) :-
    S1 >= 0.6,
    S2 >= 0.6,
    S3 >= 0.6,
    S4 >= 0.6,
    S5 >= 0.6.

% direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,0]) :- 
%     ANGLE / pi*2 =:= 0,
%     S1 >= 0, S1 =< 0.4,
%     S2 >= 0, S2 =< 0.4,
%     S3 >= 0, S3 =< 0.4,
%     S4 >= 0, S4 =< 0.4,
%     S5 >= 0, S5 =< 0.4.
% 
% direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,1]) :-
%     ANGLE / pi*2 =:= 0,
%     S3 >= 0, S3 =< 0.6,
%     S1 > 0.6,
%     S2 > 0.6, 
%     S4 >= 0, S4 =< 0.6,
%     S5 >= 0, S5 =< 0.6,
% 
% direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,1,0]) :-
%     ANGLE / pi*2 =:= 0,
%     S3 >= 0, S3 =< 0.6,
%     S4 > 0.6, 
%     S5 > 0.6,
%     S1 >= 0, S1 =< 0.6,
%     S2 >= 0, S2 =< 0.6,
% 
% direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,0]) :-
%     ANGLE / pi*2 >= 0, ANGLE / pi*2 =< (pi*2) + (pi/4),
%     S3 > 0.6,
%     S1 > 0.6, 
%     S2 > 0.6,
%     S4 >= 0, S4 =< 0.6,
%     S5 >= 0, S5 =< 0.6,
% 
% direcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [1,0,0,0]) :-
%     ANGLE / pi*2 >= 0, ANGLE / pi*2 =< (pi*2) + (pi/4),
%     S3 > 0.6,
%     S4 > 0.6, 
%     S5 > 0.6,
%     S1 >= 0, S1 =< 0.6,
%     S2 >= 0, S2 =< 0.6,
% 
% 