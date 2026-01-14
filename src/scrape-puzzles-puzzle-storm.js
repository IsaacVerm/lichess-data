const runId = crypto. randomUUID();
const now = new Date();
const date = now.toISOString().split('T')[0]; // YYYY-MM-DD
const time = now.toTimeString().split(' ')[0]; // HH:MM:SS in 24-hour format

JSON. stringify(
  Array.from(document.querySelectorAll('.puz-history__round')).map(round => {
    const resultElement = round.querySelector('good') || round.querySelector('bad');
    return {
      run_id: runId,
      date: date,
      time: time,
      rating: parseInt(round. querySelector('rating').textContent),
      href: round.querySelector('a').getAttribute('href'),
      result: round.querySelector('good') ? 'good' : 'bad',
      clock: parseInt(resultElement.textContent)
    };
  }),
  null,
  2
);
