/**
 * PiratePage Picker — per-section sticky toolbar for copy variations.
 *
 * Markup contract:
 *   <div data-pp-pick="hero" class="contents">
 *     <div data-pp-option="1" class="contents">…</div>
 *     <div data-pp-option="2" class="contents" hidden>…</div>
 *     ...
 *   </div>
 *
 * The script removes `contents` from the pick wrapper so it becomes a
 * positioning container, then injects a sticky toolbar inside it.
 * Each toolbar sticks within its own section's bounds — no overlapping.
 */
(function () {
  'use strict';

  var picks = document.querySelectorAll('[data-pp-pick]');
  if (!picks.length) return;

  var active = [];

  picks.forEach(function (pick, pi) {
    var options = pick.querySelectorAll('[data-pp-option]');
    if (!options.length) return;

    // Remove contents so wrapper is a positioning context
    pick.classList.remove('contents');
    pick.style.position = 'relative';

    // Show first, hide rest
    options.forEach(function (opt, oi) {
      if (oi === 0) {
        opt.removeAttribute('hidden');
        opt.style.display = '';
      } else {
        opt.setAttribute('hidden', '');
        opt.style.display = 'none';
      }
    });
    active[pi] = 0;

    // Build toolbar — absolutely positioned, overlays on top of section
    var toolbar = document.createElement('div');
    toolbar.setAttribute('data-pp-toolbar', '');
    toolbar.style.cssText =
      'position:absolute;top:12px;left:50%;transform:translateX(-50%);z-index:40;' +
      'display:flex;align-items:center;gap:3px;' +
      'padding:4px;' +
      'background:rgba(255,255,255,0.72);backdrop-filter:blur(16px);' +
      '-webkit-backdrop-filter:blur(16px);' +
      'border-radius:10px;' +
      'font-family:Inter,system-ui,sans-serif;' +
      'box-shadow:0 0 0 1px rgba(255,255,255,0.15),0 0 0 2px rgba(0,0,0,0.1),0 2px 8px rgba(0,0,0,0.06);' +
      'pointer-events:auto;';

    // Numbered pills — no section label
    options.forEach(function (opt, oi) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = String(oi + 1);
      btn.setAttribute('data-pp-btn', oi);
      btn.style.cssText =
        'width:28px;height:28px;display:flex;align-items:center;justify-content:center;' +
        'border-radius:7px;border:none;' +
        'font-size:12px;font-weight:600;cursor:pointer;transition:all 0.12s;' +
        'font-family:inherit;line-height:1;';
      stylePill(btn, oi === 0);
      btn.addEventListener('click', function () { doShow(pi, oi); });
      toolbar.appendChild(btn);
    });

    pick.insertBefore(toolbar, pick.firstChild);
  });

  // Sliding highlight behind active pill
  var highlights = [];

  picks.forEach(function (pick, pi) {
    var toolbar = pick.querySelector('[data-pp-toolbar]');
    if (!toolbar) return;
    // Inner wrapper so highlight can be position:absolute without clobbering toolbar
    var inner = document.createElement('div');
    inner.style.cssText = 'position:relative;display:flex;align-items:center;gap:3px;';
    // Move all buttons into inner
    while (toolbar.firstChild) inner.appendChild(toolbar.firstChild);
    toolbar.appendChild(inner);

    var hl = document.createElement('div');
    hl.style.cssText =
      'position:absolute;top:0;left:0;width:28px;height:28px;' +
      'background:#18181b;border-radius:7px;' +
      'transition:transform 0.25s cubic-bezier(0.4,0,0.2,1);' +
      'pointer-events:none;';
    inner.insertBefore(hl, inner.firstChild);
    highlights[pi] = hl;
  });

  function moveHighlight(pi, oi) {
    var hl = highlights[pi];
    if (!hl) return;
    hl.style.transform = 'translateX(' + (oi * 31) + 'px)';
  }

  function stylePill(btn, on) {
    btn.style.background = 'transparent';
    btn.style.color = on ? '#fff' : '#525252';
    btn.style.position = 'relative';
    btn.style.zIndex = '1';
  }

  function showOption(pi, oi) {
    var pick = picks[pi];
    var options = pick.querySelectorAll('[data-pp-option]');
    var buttons = pick.querySelectorAll('[data-pp-btn]');

    options.forEach(function (opt, i) {
      if (i === oi) {
        opt.removeAttribute('hidden');
        opt.style.display = '';
      } else {
        opt.setAttribute('hidden', '');
        opt.style.display = 'none';
      }
    });

    buttons.forEach(function (btn, i) {
      stylePill(btn, i === oi);
    });

    active[pi] = oi;
    moveHighlight(pi, oi);
    updateHash();
  }

  function doShow(pi, oi) {
    showOption(pi, oi);
    if (navigator.clipboard) {
      navigator.clipboard.writeText(location.href).then(function () {
        toast('URL copied');
      });
    }
  }

  function updateHash() {
    var parts = [];
    picks.forEach(function (pick, pi) {
      var options = pick.querySelectorAll('[data-pp-option]');
      var chosen = options[active[pi]];
      if (chosen) {
        parts.push(
          pick.getAttribute('data-pp-pick') + ':' +
          chosen.getAttribute('data-pp-option')
        );
      }
    });
    history.replaceState(null, '', '#' + parts.join(','));
  }

  function readHash() {
    var h = location.hash.slice(1);
    if (!h) return;
    h.split(',').forEach(function (entry) {
      var kv = entry.split(':');
      if (kv.length !== 2) return;
      picks.forEach(function (pick, pi) {
        if (pick.getAttribute('data-pp-pick') !== kv[0]) return;
        pick.querySelectorAll('[data-pp-option]').forEach(function (opt, oi) {
          if (opt.getAttribute('data-pp-option') === kv[1]) showOption(pi, oi);
        });
      });
    });
  }

  function toast(msg) {
    var el = document.getElementById('pp-pick-toast');
    if (!el) {
      el = document.createElement('div');
      el.id = 'pp-pick-toast';
      el.style.cssText =
        'position:fixed;bottom:24px;left:50%;transform:translateX(-50%) translateY(8px);' +
        'opacity:0;transition:opacity 0.3s ease,transform 0.3s cubic-bezier(0.16,1,0.3,1);' +
        'pointer-events:none;background:rgba(24,24,27,0.88);backdrop-filter:blur(8px);' +
        'color:#fff;text-align:center;' +
        'padding:8px 16px;border-radius:10px;z-index:9999;font-family:Inter,system-ui,sans-serif;' +
        'font-size:12px;font-weight:500;box-shadow:0 4px 12px rgba(0,0,0,0.2);';
      document.body.appendChild(el);
    }
    el.textContent = msg;
    el.style.opacity = '1';
    el.style.transform = 'translateX(-50%) translateY(0)';
    clearTimeout(el._t);
    el._t = setTimeout(function () {
      el.style.opacity = '0';
      el.style.transform = 'translateX(-50%) translateY(8px)';
    }, 1500);
  }

  window.addEventListener('hashchange', readHash);
  readHash();
})();
