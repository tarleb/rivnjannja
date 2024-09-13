Rivnjannja
==========

Use `equation` environments to typeset display math elements and
`\eqref` for links to those formulæ.

The name *rivnjannja* is the transliteration of the Ukrainian word
“рівняння” – "equation".

<!-- DO NOT EDIT AFTER THIS LINE! THE FOLLOWING CONTENT IS GENERATED -->

Features
--------

Rivnjannja converts specially marked spans with math content into LaTeX
`equation` environments and uses `\eqref` commands for links to these
equations.

``` markdown
[$$
  i\hbar {\frac {d}{dt}}\vert \Psi (t)\rangle =
  {\hat {H}}\vert \Psi (t)\rangle
$$]{#schroedinger .equation}

The equation [](#schroedinger){ref-type="disp-formula"} is called
the *time-dependent Schrödinger equation*.
```

With rivnjannja, this becomes

``` native
```

``` latex
\begin{equation}\label{schroedinger}

  i\hbar {\frac {d}{dt}}\vert \Psi (t)\rangle =
  {\hat {H}}\vert \Psi (t)\rangle

\end{equation}

The equation \eqref{schroedinger} is called the \emph{time-dependent
Schrödinger equation}.
```
