# Stuff to add to Anki?

> _See `./__ANKI__` in local folder (not in repo)_
>
> 1. Write it down (a brief summary of a learning point)
> 2. How well do you understand? How well do you remember?
> 3. Sometimes, having a set of notes, or an example on file is enough.
> 4. If you understand the idea well enough, is it really worth the overhead to add to Anki?
> 5. If it's warranted, create an example in your own words
> 6. For more complex ideas, 3 times, 3 ways
> 7. Mixed learning techniques (learning styles, formats)
> 8. Interleave where possible (similar ideas in lisp/elm)

Learning and teaching with programming takes quite a bit of breaking things down and moving up in small steps, so that the student understands what options they have, and how to write things more succinctly.

- [ ] Which texts or online learning get it right?
- [ ] How could you break down that learning for better Anki cards?

## Candidates for an Anki card

### Chapter 01/02

1. `++` and `==` as these are different from Lisp
2. Higher order functions
3. An anonymous function example
4. What is a higher order function?
5. Can you mix types in a list?
6. A quick note on the DOM?
7. We improved `selectedUrl` in `viewThumbnail` which looks much better using `classList` http://tinyurl.com/5enp9ndh
8. The `Html` module can make for some verbose code (see 7). Ways to cutcodedown?
9. Explain partial application in the `List.map (viewThumbnail ...)` section.
10. See **[`notes.elm`](https://github.com/badlydrawnrob/elm-playground/blob/8d168bd65fbd4fde7b8d428bb8a0f5dd9cd7dc70/elm-in-action/02/notes/notes.elm#L228)**: A couple of examples of currying [(partially applying functions)](https://www.codingexercises.com/guides/quickstart-elm-part-7) — also in [Scheme](http://tinyurl.com/scheme-lang-currying). See Table 2.1 (add a note on difference between default and tupled functions)
    - Why does the function work after it was changed from this version? http://tinyurl.com/elm-lang-before-currying
    - A sketch might be handy (to show [how it's actually called twice](https://livebook.manning.com/forum?p=1&comment=503513&page=1&product=rfeldman))
    - Is there something specific about the _order_ of the arguments, and would it work the other way around? (no)
11. Understanding [`Html msg`](http://tinyurl.com/elm-lang-html-msg)