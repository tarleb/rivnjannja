Rivnjannja
==========

Create format-native markup for labeled equations and links to
those formulæ. LaTeX and Typst are supported as output formats.

The filter is particularly well suited to be run after
[querverweis][], which generates many of the structures that
rivnjannja expects.

The name *rivnjannja* is the transliteration of the Ukrainian word
“рівняння” – "equation".

[querverweis]: https://github.com/tarleb/querverweis

<!-- DO NOT EDIT AFTER THIS LINE! THE FOLLOWING CONTENT IS GENERATED -->

LaTeX
-----

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

``` latex
\begin{equation}\label{schroedinger}

  i\hbar {\frac {d}{dt}}\vert \Psi (t)\rangle =
  {\hat {H}}\vert \Psi (t)\rangle

\end{equation}

The equation \eqref{schroedinger} is called the \emph{time-dependent
Schrödinger equation}.
```

### Typst

The [Typst](https://typst.app) typesetting system supports reference
links to numbered equations.

``` markdown
[$$
  i\hbar {\frac {d}{dt}}\vert \Psi (t)\rangle =
  {\hat {H}}\vert \Psi (t)\rangle
$$]{#schroedinger .equation}

The equation [1](#schroedinger){ref-type="disp-formula"} is called
the *time-dependent Schrödinger equation*.
```

Rivnjannja converts this to

``` typst
$ i planck.reduce frac(d, d t) \| Psi \( t \) angle.r = hat(H) \| Psi \( t \) angle.r $ <schroedinger>

The equation @schroedinger[] is called the #emph[time-dependent
Schrödinger equation].
```

#### Typst Header Includes

The generated Typst code expects equation numbering to be enabled, as
referencing an unnumbered equation will lead to a compilation error.

``` markdown
[$$ x $$]{#test .equation number=1}

See equation [(1)]{#test}!
```

The filter adds the necessary code to the `header-includes` meta value,
adding a directive that causes labeled equations to be numbered.

``` typst
// Number labeled equations
#set math.equation(numbering: "(1)")
#show math.equation: it => {
  if it.block and not it.has("label") [
    // "uncount" equations without labels
    #counter(math.equation).update(v => v - 1)
    // Empty label to avoid recursion
    #math.equation(it.body, block: true, numbering: none)#label("")
  ] else {
    it
  }
}
```
