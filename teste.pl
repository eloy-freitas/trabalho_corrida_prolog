% base
menorElemDaLista([H|T], Index) :- 
    menorElemDaLista([H|T], Index, H, MenorIndex, 1).

menorElemDaLista([], MenorIndex, _, MenorIndex, _).

menorElemDaLista([H|T], Index, Menor, MenorIndex, Count) :-
    H =< Menor,
    Aux1 is H,
    Aux2 is Count + 1,
    menorElemDaLista(T, Index, Aux1, Count, Aux2). 

menorElemDaLista([_|T], Index, Menor, MenorIndex, Count) :-
    Aux1 is Count + 1,
    menorElemDaLista(T, Index, Menor, MenorIndex, Aux1). 