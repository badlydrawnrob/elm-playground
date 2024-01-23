# Stuff to add to Anki?

> See the Books app on Mac for highlighted eBook
> _See `./__ANKI__` in local folder (not in repo)_.

Don't add cards recklessly. Is it really worth the overhead to create and revise this card? Remember your "bin first" approach to grouping, filtering, and timeboxing tasks (and your tendency to get side-tracked!)

The book uses quite a few javascript examples and a lot of terminology that needn't be consigned to memory — shared concepts and important keywords/terminology could be useful. <mark>Mark them with highlights</mark>.

For now, I'm only really interested in learning the language Elm so javascript notes aren't useful (to me).[^1]

## Lazy loading of cards

> ⚠️ **To what level do I want to learn programming?**[^2]
> 🎯 **How much do I care?**[^3]
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

Learning and teaching with programming takes quite a bit of breaking things down and moving up in small steps, so that the student understands what options they have, and how to write things more succinctly.

Looking back at some of the [Racket lang challenges](https://github.com/badlydrawnrob/racket-playground/issues/1) I've really forgotten quite a bit, and the functional examples seem a verbose and long-winded.

- [ ] Which texts or online learning get it right?
- [ ] How to break down that learning for better Anki cards?
- [ ] Is linking cards to Chapter of the book enough?

## Candidates for an Anki card

## Chapter 03

> After our initial small app, we get some more feature requests and have to improve it. They should be prioritised before you even start!

1. Draw sketches to show the black box procedures[^4]
    - One of them is _currying_
    - One of them is _random numbers_
2. A DOM picture and a Elm runtime picture
3. Create a document that shows:
    - A simple _static_ model (basic data)
    - A `Browser` dynamic model (with a message)
4. Give a brief introduction to [`Type Variables`](http://tinyurl.com/elm-lang-type-variables)
    - For example `number` is a type variable.
    - `fromList : List elementType -> Array elementType`
5. A basic `model->view->update` — a view takes a model and returns a list of Html nodes, user events like clicks get translated into message values, messages get run through the update function to produce a new model, after an update a new model is sent to the view function to determine the new dom, so on (reduce this down to 3 simple steps)



[^1]: I have color-coordinated some sections with highlights on the _Elm in Action_ ebook

[^2]: Remember to be careful with your time and energy! Eli5, RRr, Bin first, filter, and timebox tasks.

[^3] Always. Always [keep in mind your learning target](https://github.com/badlydrawnrob/elm-playground/issues/9).

[^4]: A black box procedure should be obvious to it's input and output, but the user _does not have to know_ anything about the internal mechanism. You should be able to change the inner workings and keep the same inputs and outputs (or at least, refactor with minimal fuss)
