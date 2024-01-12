# Stuff to add to Anki?

> _See `./__ANKI__` in local folder (not in repo)_. Don't add cards recklessly. Is it really worth the overhead to create and revise this card? Remember your "bin first" approach to grouping, filtering, and timeboxing tasks (and your tendency to get side-tracked!)
>
> The book uses quite a few javascript examples, and a lot of terminology that needn't be consigned to memory (I don't think) — important keywords and terminology could be useful. Mark them with highlights.
>
> 1. **Write it down** (a brief summary of a learning point)
> 2. **Group related learning points!**
> 3. How well do you **understand?** How well do you **remember?**
> 4. Is having an example on file, or **a set of notes enough?**
> 5. **Do I understand the idea well enough?** Will it make sense in a few months?
> 6. If it's warranted, **write out a "to-do" Anki card item as a sentence of intent**, ideally in your own words.
> 7. For more complex ideas, **[3 times, 3 ways](https://github.com/badlydrawnrob/anki/issues/93)**
> 8. **Mixed learning techniques** (learning styles, formats) — add a link, a video, whatever.
> 9. **Interleave** where possible (e.g: similar ideas in lisp/elm)
> 10. **Group, filter, timebox** a potential card (using other mental models if needed)
> 11. **Create an example card in your own words!**

- To what level do I want to learn programming?
- How much do I care?

Learning and teaching with programming takes quite a bit of breaking things down and moving up in small steps, so that the student understands what options they have, and how to write things more succinctly. Looking back at some of the [Racket lang challenges](https://github.com/badlydrawnrob/racket-playground/issues/1) I've really forgotten quite a bit, and the functional examples seem a verbose and long-winded.

- [ ] Which texts or online learning get it right?
- [ ] How could you break down that learning for better Anki cards?

## Candidates for an Anki card

### Chapter 01/02

1. `++` and `==` as these are different from Lisp
2. Higher order functions
3. <mark>An anonymous function example</mark>
4. What is a higher order function?
5. Can you mix types in a list?
6. A quick note on the DOM?
7. We improved `selectedUrl` in `viewThumbnail` which looks much better using `classList` http://tinyurl.com/5enp9ndh
8. The `Html` module can make for some verbose code (see 7). Ways to cutcodedown?
9. <mark>Explain partial application in the `List.map (viewThumbnail ...)` section. Also known as _currying_.</mark>
10. See **[`notes.elm`](https://github.com/badlydrawnrob/elm-playground/blob/8d168bd65fbd4fde7b8d428bb8a0f5dd9cd7dc70/elm-in-action/02/notes/notes.elm#L228)**: A couple of examples of currying [(partially applying functions)](https://www.codingexercises.com/guides/quickstart-elm-part-7) — also in [Scheme](http://tinyurl.com/scheme-lang-currying). See Table 2.1 (add a note on difference between default and tupled functions)
    - Why does the function work after it was changed from this version? http://tinyurl.com/elm-lang-before-currying
    - A sketch might be handy (to show [how it's actually called twice](https://livebook.manning.com/forum?p=1&comment=503513&page=1&product=rfeldman))
    - Is there something specific about the _order_ of the arguments, and would it work the other way around? (no)
11. <mark>Understanding [`Html msg`](http://tinyurl.com/elm-lang-html-msg)</mark>
12. <mark>What the fuck does [`|` pipe](https://github.com/badlydrawnrob/elm-playground/blob/eeec50661c2d3eaddb17862380895e7be658500d/elm-in-action/02/notes/notes.elm#L272) do?</mark> (this is quite different from lisp) — [answer here](https://elm-lang.org/docs/records#updating-records)
13. [Difference](https://github.com/badlydrawnrob/elm-playground/commit/5e8dcaf8a02ab3bd25a677280a42d7cc9648eaea#diff-cf788fcfa2aae55b8c1aa182e6a277971730a9d5203ef741f109f311a8c8c9ba) between a <mark>static model</mark>, and a <mark>dynamic one</mark>. See [here](https://elmprogramming.com/model-view-update-part-1.html) — probably a simple before/after example will do here.
14. Create a document that shows a basic model with a <mark>message</mark> (include the initial basic images too)
