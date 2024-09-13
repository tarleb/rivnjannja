# Features

Rivnjannja converts specially marked spans with math content into
LaTeX `equation` environments and uses `\eqref` commands for links
to these equations.

``` markdown {#input}
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

``` latex {#output}
\begin{equation}\label{schroedinger}

  i\hbar {\frac {d}{dt}}\vert \Psi (t)\rangle =
  {\hat {H}}\vert \Psi (t)\rangle

\end{equation}

The equation \eqref{schroedinger} is called the \emph{time-dependent
Schrödinger equation}.
```
