const runId = crypto.randomUUID();

JSON.stringify(
  Array.from(document.querySelectorAll('.puz-history__round')).map(round => {
    const resultElement = round.querySelector('good') || round.querySelector('bad');
    return {
      run_id: runId,
      rating: parseInt(round. querySelector('rating').textContent),
      href: round.querySelector('a').getAttribute('href'),
      result: round.querySelector('good') ? 'good' : 'bad',
      clock: parseInt(resultElement.textContent)
    };
  }),
  null,
  2
);
