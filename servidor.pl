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
%:- use_module(library(http/http_error)).
%:- debug.

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

obter_controles([X,Y,ANGLE,S1,S2,S3,S4,S5], [F,R,E,D]) :- qualAcao([X,Y,ANGLE,S1,S2,S3,S4,S5], [F,R,E,D]).

naoMembro([],_) :- !.
naoMembro([H|T],B) :- H \= B,
	naoMembro(T,B).

qualAcao(SENSORES, ACAO) :-
	todasAcoes(SENSORES, ACOES),
	melhorAcao(SENSORES, ACOES, MELHOR),
	ACAO = MELHOR. 

todasAcoes([X,Y,ANGLE,S1,S2,S3,S4,S5], ACOES) :-
	todasAcoes([X,Y,ANGLE,S1,S2,S3,S4,S5], ACOES, []).

%passo
todasAcoes([X,Y,ANGLE,S1,S2,S3,S4,S5], ACOES, ListAux) :-
	acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO),
	naoMembro(ListAux, ACAO),
	Aux = [ACAO | ListAux],
	todasAcoes([X,Y,ANGLE,S1,S2,S3,S4,S5], ACOES, Aux).

%base
todasAcoes(ACAO, ACOES, ACOES) :- !.

avalia([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO, PONTUACAO) :- 
	PONTUACAO is S1*0.1 + S2*0.3 + S3*0.5 + S4*0.3 + S5*0.1.

melhorAcao(SENSORES, ACOES, MELHOR) :- 
	melhorAcao(SENSORES, ACOES, MELHOR, [], 0).

%passo
melhorAcao(SENSORES, [H|T], MELHOR, AuxMelhor, AuxMelhorPontuacao) :-
	avalia(SENSORES, H, PONTUACAO),
	AuxMelhorPontuacao < PONTUACAO,
	Aux = PONTUACAO,
	melhorAcao(SENSORES, T, MELHOR, H, Aux).

melhorAcao(SENSORES, [H|T], MELHOR, AuxMelhor, AuxMelhorPontuacao) :-
	avalia(SENSORES, H, PONTUACAO),
	melhorAcao(SENSORES, T, MELHOR, AuxMelhor, AuxMelhorPontuacao).

%base
melhorAcao(SENSORES, [], MELHOR, MELHOR, _).

acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
	S1 < 0.8,
    S2 < 0.5,
    S3 < 0.4,
    S4 < 0.5,
    S5 < 0.8,
	ACAO = [1,0,0,0].

% regras com angulo

% esquerda
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    abs(ANGLE/(pi*2) - (pi*2)) < (pi*2),
    S4 >= 0.5,
    S4 < 0.75,
    S5 >= 0.5,
    S5 < 0.75,
    S1 + S2 < S4 + S5, 
	ACAO = [1,0,1,0].

% esquerda
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    abs(ANGLE/(pi*2) - (pi*2)) < (pi*2),
    S4 >= 0.5,
    S4 < 0.75,
    S5 >= 0.5,
    S5 < 0.75,
    S3 + S2 < S4 + S5, 
	ACAO = [1,0,1,0].

% esquerda
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    abs(ANGLE/(pi*2) - (pi*2)) < (pi*2),
    S4 >= 0.5,
    S4 < 0.75,
    S3 >= 0.5,
    S3 < 0.75,
    S3 + S2 < S3 + S4, 
	ACAO = [1,0,1,0].

% esquerda
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    abs(ANGLE/(pi*2) - (pi*2)) < (pi*2),
    S4 >= 0.5,
    S4 < 0.75,
    S3 >= 0.5,
    S3 < 0.75,
    S1 + S2 < S3 + S4, 
	ACAO = [1,0,1,0].

% fim regras com angulo

% esquerda
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S4 >= 0.5,
    S4 < 0.75,
    S5 >= 0.5,
    S5 < 0.75,
    S1 + S2 < S4 + S5, 
	ACAO = [1,0,1,0].

% esquerda
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S4 >= 0.5,
    S4 < 0.75,
    S5 >= 0.5,
    S5 < 0.75,
    S3 + S2 < S4 + S5, 
	ACAO = [1,0,1,0].

% esquerda
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S4 >= 0.5,
    S4 < 0.75,
    S3 >= 0.5,
    S3 < 0.75,
    S3 + S2 < S3 + S4, 
	ACAO = [1,0,1,0].

% esquerda
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S4 >= 0.5,
    S4 < 0.75,
    S3 >= 0.5,
    S3 < 0.75,
    S1 + S2 < S3 + S4, 
	ACAO = [1,0,1,0].

% esquerda
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S3 >= 0.5,
    S3 < 0.75,
    S4 >= 0.5,
    S4 < 0.75,
    S5 >= 0.5,
    S5 < 0.75,
    S1 + S2 + S3 < S3 + S4 + S5, 
	ACAO = [1,0,1,0].

% regras com ângulo
% direita
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    abs(ANGLE/(pi*2) - (pi*2)) > (pi*2),
    S1 >= 0.45,
    S1 < 0.75,
    S2 >= 0.45,
    S2 < 0.75,
    S3 + S4 < S1 + S2, 
	ACAO = [1,0,0,1].

% direita
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    abs(ANGLE/(pi*2) - (pi*2)) > (pi*2),
    S1 >= 0.45,
    S1 < 0.75,
    S2 >= 0.45,
    S2 < 0.75,
    S4 + S5 < S1 + S2, 
	ACAO = [1,0,0,1].

% direita
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    abs(ANGLE/(pi*2) - (pi*2)) > (pi*2),
    S2 >= 0.45,
    S2 < 0.75,
    S3 >= 0.45,
    S3 < 0.75,
    S3 + S4 < S2 + S3, 
	ACAO = [1,0,0,1].

% direita
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    abs(ANGLE/(pi*2) - (pi*2)) > (pi*2),
    S2 >= 0.45,
    S2 < 0.75,
    S3 >= 0.45,
    S3 < 0.75,
    S4 + S5 < S2 + S3, 
	ACAO = [1,0,0,1].


% direita
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S1 >= 0.45,
    S1 < 0.75,
    S2 >= 0.45,
    S2 < 0.75,
    S3 + S4 < S1 + S2, 
	ACAO = [1,0,0,1].

% direita
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S1 >= 0.45,
    S1 < 0.75,
    S2 >= 0.45,
    S2 < 0.75,
    S4 + S5 < S1 + S2, 
	ACAO = [1,0,0,1].

% direita
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S2 >= 0.45,
    S2 < 0.75,
    S3 >= 0.45,
    S3 < 0.75,
    S3 + S4 < S2 + S3, 
	ACAO = [1,0,0,1].

% direita
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S2 >= 0.45,
    S2 < 0.75,
    S3 >= 0.45,
    S3 < 0.75,
    S4 + S5 < S2 + S3, 
	ACAO = [1,0,0,1].

% direita
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S1 >= 0.45,
    S1 < 0.75,
    S2 >= 0.45,
    S2 < 0.75,
    S3 >= 0.45,
    S3 < 0.75,
    S3 + S4 + S5 < S1 + S2 + S3, 
	ACAO = [1,0,0,1].

%% re para esquerda
%acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
%    S2 + S3 >= 0.75,
%	ACAO = [0,1,1,0].
%
%% re para esquerda
%acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
%    S3 + S4 >= 0.75,
%	ACAO = [0,1,0,1].

% re
acao([X,Y,ANGLE,S1,S2,S3,S4,S5], ACAO) :-
    S2 > 0.75,
    S3 > 0.75,
	S4 > 0.75,
	ACAO = [0,1,0,0].
	
    
% http://localhost:8080/action?s1=0.7020670527338634&s2=0.8141394058422182&s3=0.8282872011572386&s4=0&s5=0.273793940822295&x=77.5&y=-434.4310571340031&angle=0