%include agda.fmt
\usetikzlibrary{positioning}

\section{The 3×3 lemma}
\label{sec:threebythree}

In this section, we present another example of a problem whose
formalization in Agda has been made possible using cubical ideas.  This
problem, called the 3×3 lemma, has been used in particular in the
construction of the Hopf fibration and in the computation of |π₄ S³|.

We first need to define the notion of pushout: given three types |A|, |B| and
|C| and two maps |f : C → A| and |g : C → B|
\begin{center}
\begin{tikzpicture}
  \node (A)              {|A|};
  \node (C) [right=of A] {|C|};
  \node (B) [right=of C] {|B|};

  \draw[->] (C) to node[above] {|f|} (A);
  \draw[->] (C) to node[above] {|g|} (B);
\end{tikzpicture}
\end{center}
%
their pushout is the higher inductive type |Pushout f g| with the following
three constructors:
\begin{code}
  inl : A → Pushout f g
  inr : B → Pushout f g
  push : (c : C) → Path (inl (f c)) (inr (g c))
\end{code}
%
A pushout is like a sum type |A + B|, except certain instances of |inl|
and |inr| are ``glued'' together (see \citep{uf13hott-book}).  The
corresponding elimination rule is:
%
\begin{code}
  Pushout-elimo : {A B C : Type} {f : C → A} {g : C → B}
   (P : Pushout f g → Type) 
   (l : (a : A) → P (inl a)) (r : (b : B) → P (inr b))
   (p : (c : C) → PathOver P (push c) (l (f c)) (r (g c))
   (x : Pushout f g) → P x
\end{code}
As usual, we have definitional reduction rules on points and
propositional reduction rules on paths.  
\ignore{
\begin{code}
  Pushout-elimo P l r p (inl a) ≡ l a
  Pushout-elimo P l r p (inr b) ≡ r b

  βpush/elimo : (c : C) →
   Path (apdo (Pushout-elimo P l r p) (push c)) (p c)
\end{code}}
%

The problem is now the following. Given nine types |Aᵢⱼ|, twelve
maps |fᵢⱼ| and four equalities |sᵢⱼ| as follows:
\begin{center}
\begin{tikzpicture}
  \node (A)              {|A₀₀|};
  \node (B) [right=of A] {|A₀₂|};
  \node (C) [right=of B] {|A₀₄|};
  \node (D) [below=of A] {|A₂₀|};
  \node (E) [below=of B] {|A₂₂|};
  \node (F) [below=of C] {|A₂₄|};
  \node (G) [below=of D] {|A₄₀|};
  \node (H) [below=of E] {|A₄₂|};
  \node (I) [below=of F] {|A₄₄|};

  \draw[->] (B) to node[above] {|f₀₁|} (A);
  \draw[->] (B) to node[above] {|f₀₃|} (C);
  \draw[->] (E) to node[above] {|f₂₁|} (D);
  \draw[->] (E) to node[above] {|f₂₃|} (F);
  \draw[->] (H) to node[above] {|f₄₁|} (G);
  \draw[->] (H) to node[above] {|f₄₃|} (I);
  \draw[->] (D) to node[left] {|f₁₀|} (A);
  \draw[->] (D) to node[left] {|f₃₀|} (G);
  \draw[->] (E) to node[left] {|f₁₂|} (B);
  \draw[->] (E) to node[left] {|f₃₂|} (H);
  \draw[->] (F) to node[left] {|f₁₄|} (C);
  \draw[->] (F) to node[left] {|f₃₄|} (I);

  \draw[->,double] (B) to node[above left]  {|s₁₁|} (D);
  \draw[->,double] (B) to node[right, near start] {|s₁₃|} (F);
  \draw[->,double] (H) to node[right, near end]  {|s₃₁|} (D);
  \draw[->,double] (H) to node[above left] {|s₃₃|} (F);
\end{tikzpicture}
\end{center}
%
where the double arrows mean that we have for instance
\begin{code}
s₁₁ : (x : A₂₂) → Path (f₀₁ (f₁₂ x)) (f₁₀ (f₂₁ x))
\end{code}
we want to compute its “two-dimensional pushout”. There are at least two ways to
do that. We can either first compute the pushout of each of the three lines,
which fit together in a diagram as follows:
%
\begin{center}
\begin{tikzpicture}
  \node (A)              {|A₀•|};
  \node (D) [below of=A] {|A₂•|};
  \node (G) [below of=D] {|A₄•|};

  \draw[->] (D) to node[left] {|f₁•|} (A);
  \draw[->] (D) to node[left] {|f₃•|} (G);
\end{tikzpicture}
\end{center}
%
and then compute the pushout of the resulting diagram, which we will denote by
|A◾•|.  But we can also first compute the pushouts of the three columns:
\begin{center}
\begin{tikzpicture}
  \node (A)              {|A•₀|};
  \node (B) [right=of A] {|A•₂|};
  \node (C) [right=of B] {|A•₄|};

  \draw[->] (B) to node[above] {|f•₁|} (A);
  \draw[->] (B) to node[above] {|f•₃|} (C);
\end{tikzpicture}
\end{center}
%
and then the pushout |A•◾| of the resulting diagram.  The 3×3 lemma
states that the two types |A◾•| and |A•◾| are equivalent.

First, we explain how to construct the map |f₁•| (the maps |f₃•|, |f•₁|
and |f•₃| are defined in a similar way). To make things clearer, until
the end of this section we will annotate the constructors |inl|, |inr|
and |push| by the |ᵢⱼ| corresponding to their return type.

The map |f₁• : A₂• → A₀•| is defined using the recursion rule of the
pushout. It sends the point |inl₂• x| to |inl₀• (f₁₀ x)|. It sends the
point |inr₂• x| to |inr₀• (f₁₄ x)|. Finally, the path |push₂• x| (which
goes from |inl₂• (f₂₁ x)| to |inr₂• (f₂₃ x)|) has to be sent to a path
from |inl₀• (f₁₀ (f₂₁ x))| to |inr₀• (f₁₄ (f₂₃ x))|. The path |push₀•
(f₁₂ x)| doesn’t work directly, because it goes from |inl₀• (f₀₁ (f₁₂
x))| to |inr₀• (f₀₃ (f₁₂ x))|, but we can compose to the left and to the
right with the equalities |s₁₁| and |s₁₃| to make the endpoints
match. Given the direction of the arrows, this can be done conveniently
using |fill-square-right| or an analogous |fill-square-left| operation,
which produces the left side of a square from the top and right and
bottom.  We notate these operations as |Kan-right| and |Kan-left| in
this section.

Hence, the complete Agda definition of |f₁•| is the following:

\begin{code}
  f₁• : A₂• → A₀•
  f₁• = Pushout-rec  (λ x → inl₀• (f₁₀ x))
                     (λ x → inr₀• (f₁₄ x))
                     (λ y → Kan-right  (ap inl₀• (s₁₁ y))
                                       (ap inr₀• (s₁₃ y))
                                       (push₀• (f₁₂ y)))
\end{code}

To prove that |A◾•≃A•◾|, we construct two maps back and forth and prove
that the two compositions are the identity.  Even though the statement
of the problem involves only higher inductive types (pushouts) with only
point and path constructors, we are nesting them by considering a
pushout of pushouts, so we will have to deal with squares.  The
construction of the maps and of the equalities go by double induction on
the pushouts, hence there will be essentially nine steps each time: four
for the points coming from |A₀₀|, |A₄₀|, |A₀₄| and |A₄₄|, four for the
lines coming from |A₀₂|, |A₄₂|, |A₂₀|, |A₄₀|, and one for the squares
coming from |A₂₂|.

It is worth noting that something nontrivial happens in the case of the squares
coming from |A₂₂|. Indeed, the one-dimensional constructor of |A◾•| is
\begin{code}
  push◾• : (y : A₂•) → Path (inl◾• (f₁• y)) (inr◾• (f₃• y))
\end{code}
%
and the one-dimensional constructor of |A₂•| is
\begin{code}
  push₂• : (x : A₂₂) → Path (inl₂• (f₂₁ x)) (inr₂• (f₂₃ x))
\end{code}
%
hence the square in |A◾•| corresponding to a point |x : A₂₂| is the term
|apdo push◾• (push₂• x)| which is of type
\begin{code}
PathOver  (λ y → Path (inl◾• (f₁• y)) (inr◾• (f₃• y))) (push₂• x)
          (push◾• (inl₂• (f₂₁ x))) (push◾• (inr₂• (f₂₃ x)))
\end{code}
%
Using |PathOver-=-eqv| we get a square of type
%
\begin{code}
Square  (push◾• (inl₂• (f₂₁ x)))
        (ap (λ y → inl◾• (f₁• y)) (push₂• x))
        (ap (λ y → inr◾• (f₃• y)) (push₂• x))
        (push◾• (inr₂• (f₂₃ x)))
\end{code}
%
Using |whisker-square|, we can reduce the top and bottom.
For the top: unfusing the |ap| gives |ap inl◾• (ap f₁• (push₂• x))|, and
reducing the pushout recursion on |push| goes from |ap f₁• (push₂•
x)| to |Kan-right (ap inl₀• (s₁₁ y)) (ap inr₀• (s₁₃ y)) (push₀• (f₁₂
x))|. Finally, using the fact that Kan operations commute with |ap|, this is the same as
%
\begin{code}
Kan-right  (ap inl◾• (ap inl₀• (s₁₁ x)))
           (ap inl◾• (ap inr₀• (s₁₃ x)))
           (ap inl◾• (push₀• (f₁₂ x)))
\end{code}

Hence, the square in |A◾•| we have is of type
%
\begin{code}
Square  (push◾• (inl₂• (f₂₁ x)))
        (Kan-right  (ap inl◾• (ap inl₀• (s₁₁ x)))
                    (ap inl◾• (ap inr₀• (s₁₃ x)))
                    (ap inl◾• (push₀• (f₁₂ x))))
        (Kan-right  (ap inr◾• (ap inl₄• (s₃₁ x)))
                    (ap inr◾• (ap inr₄• (s₃₃ x)))
                    (ap inr◾• (push₄• (f₃₂ x))))
        (push◾• (inr₂• (f₂₃ x)))
\end{code}
%
which we will shorten to
\begin{code}
Square p₂₁ (Kan-right p₁₁ p₁₃ p₁₂) (Kan-right p₃₁ p₃₃ p₃₂) p₂₃
\end{code}
Note that the |pᵢⱼ| fit in the following diagram:
%
\begin{center}
\begin{tikzpicture}
  \node (A) {};
  \node (B) [right of=A] {};
  \node (C) [below right of=B] {};
  \node (D) [below of=C] {};
  \node (E) [below left of=D] {};
  \node (F) [left of=E] {};
  \node (G) [above left of=F] {};
  \node (H) [above of=G] {};

  \draw[->] (A) to node[below] {|p₁₂|} (B);
  \draw[->] (B) to node[above right] {|p₁₃|} (C);
  \draw[->] (C) to node[left] {|p₂₃|} (D);
  \draw[->] (E) to node[below right] {|p₃₃|} (D);
  \draw[->] (F) to node[above] {|p₃₂|} (E);
  \draw[->] (F) to node[below left] {|p₃₁|} (G);
  \draw[->] (H) to node[right] {|p₂₁|} (G);
  \draw[->] (A) to node[above left] {|p₁₁|} (H);
\end{tikzpicture}
\end{center}

However, when constructing the map |A•◾ → A◾•| using a double induction on the
pushouts, we can check that what we need is a square in |A◾•| of type
%
\begin{code}
Square p₁₂ (Kan-left p₁₁ p₃₁ p₂₁) (Kan-left p₁₃ p₃₃ p₂₃) p₃₂
\end{code}
%
% \begin{comment}
% to : A•◾ → A◾•
% to (inl x) = to-l x
% to (inr x) = to-r x
% ap to (push x) = to-p x
% 
% to-l : A•₀ → A◾•
% to-l (inl x) = inl (inl x)
% to-l (inr x) = inr (inl x)
% ap to-l (push x) = push (inl x)
% 
% to-r : A•₄ → A◾•
% to-r (inl x) = inl (inr x)
% to-r (inr x) = inr (inr x)
% ap to-r (push x) = push (inr x)
% 
% to-p : (x : A•₂) → to-l (f•₁ x) = to-r (f•₃ x)
% to-p (inl x) = ap inl (push x)
% to-p (inr x) = ap inr (push x)
% ap to-p (push x) =
% 
% 
% push x : inl (f₁₂ x) = inr (f₃₂ x)
% 
% ap inl (push (f₁₂ x)) =/ ap inr (push (f₃₂ x))
% 
% over
% ap to-l (ap f₁• (push x))
% == ap to-l (Kan-left (ap inl (s₁₁ x)) (ap inr (s₃₁ x)) (push (f₂₁ x)))
% == Kan-left (ap inl (ap inl (s₁₁ x))) (ap inr (ap inl (s₃₁ x))) (push (inl (f₂₁ x)))
% \end{comment}
%
Hence to define the map |A•◾ → A◾•|, we need a map between those two square
types, and in order to do the complete proof that |A•◾ ≃ A◾•| we will need
an equivalence between them.

One way to do it is as follows: we first do a path induction on |p₁₁|, |p₁₃|,
|p₃₁| and |p₃₃| and use the fact that for every |p| there is a path between
|Kan-right id id p| and |p| and a path between |Kan-left id id p| and |p|, and
then we can apply |square-symmetry-eqv|.

Another way to see it is as a three-dimensional cube:
\begin{center}
\begin{tikzpicture}
  \coordinate (A) at (0,3);
  \coordinate (B) at (2,3);
  \coordinate (C) at (3,2);
  \coordinate (D) at (3,0);
  \coordinate (E) at (2,1);
  \coordinate (F) at (0,1);
  \coordinate (G) at (1,0);
  \coordinate (H) at (1,2);

  \draw[->] (A) to node[above] {|p₁₂|} (B);
  \draw[->] (B) to node[below left] {|p₁₃|} (C);
  \draw[->] (C) to node[right] {|p₂₃|} (D);
  \draw[->] (E) to node[below left] {|p₃₃|} (D);
  \draw[->] (F) to node[below,near end] {|p₃₂|} (E);
  \draw[->] (F) to node[below left] {|p₃₁|} (G);
  \draw[->] (H) to node[right,near start] {|p₂₁|} (G);
  \draw[->] (A) to node[below left] {|p₁₁|} (H);
\end{tikzpicture}
\end{center}
%
If we fill the left, right, top, and bottom, the front
and back faces are exactly the two square types 
that we want to prove equivalent.  Thus, it suffices to observe that, by the Kan
filling operations, any four faces of a cube that form a tube determine
an equivalence between the other two opposing faces.
