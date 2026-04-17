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

    // Remove contents so wrapper participates in layout
    pick.classList.remove('contents');
    pick.style.overflow = 'clip';

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

    // Build toolbar — sticky, draggable via translate to keep sticky behavior
    var toolbar = document.createElement('div');
    toolbar.setAttribute('data-pp-toolbar', '');
    toolbar.style.cssText =
      'position:sticky;top:16px;z-index:40;' +
      'width:fit-content;margin:0 auto -32px;' +
      'display:flex;align-items:center;gap:2px;' +
      'padding:3px;' +
      'background:rgba(255,255,255,0.7);backdrop-filter:blur(12px);' +
      '-webkit-backdrop-filter:blur(12px);' +
      'border-radius:9px;' +
      'font-family:Inter,system-ui,sans-serif;' +
      'box-shadow:0 0 0 1px rgba(0,0,0,0.08),0 1px 3px rgba(0,0,0,0.06);' +
      'pointer-events:auto;';

    // Drag handle — 3 horizontal bars, appended after pills below
    var grip = document.createElement('div');
    grip.style.cssText =
      'display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;' +
      'width:16px;height:26px;cursor:grab;flex-shrink:0;' +
      'margin-left:2px;user-select:none;opacity:0.35;' +
      'transition:opacity 0.12s;';
    for (var gi = 0; gi < 3; gi++) {
      var bar = document.createElement('div');
      bar.style.cssText = 'width:10px;height:1.5px;background:#525252;border-radius:1px;';
      grip.appendChild(bar);
    }
    grip.addEventListener('mouseenter', function () { grip.style.opacity = '0.7'; });
    grip.addEventListener('mouseleave', function () { if (!dragState) grip.style.opacity = '0.35'; });
    // grip is appended after pills in the loop below

    var dragState = null;

    grip.addEventListener('mousedown', function (e) {
      e.preventDefault();
      // Capture current visual position, switch to absolute
      var rect = toolbar.getBoundingClientRect();
      var pickRect = pick.getBoundingClientRect();
      pick.style.position = 'relative';
      toolbar.style.position = 'absolute';
      toolbar.style.margin = '0';
      toolbar.style.left = (rect.left - pickRect.left) + 'px';
      toolbar.style.top = (rect.top - pickRect.top + pick.scrollTop) + 'px';
      dragState = { offsetX: e.clientX - rect.left, offsetY: e.clientY - rect.top };
      grip.style.cursor = 'grabbing';
    });

    document.addEventListener('mousemove', function (e) {
      if (!dragState) return;
      var pickRect = pick.getBoundingClientRect();
      var tbW = toolbar.offsetWidth, tbH = toolbar.offsetHeight;
      var x = e.clientX - dragState.offsetX - pickRect.left;
      var y = e.clientY - dragState.offsetY - pickRect.top;
      // Clamp inside pick wrapper
      x = Math.max(0, Math.min(pickRect.width - tbW, x));
      y = Math.max(0, Math.min(pickRect.height - tbH, y));
      toolbar.style.left = x + 'px';
      toolbar.style.top = y + 'px';
    });

    document.addEventListener('mouseup', function () {
      if (!dragState) return;
      dragState = null;
      grip.style.cursor = 'grab';
      grip.style.opacity = '0.35';
    });

    // Numbered pills — no section label
    options.forEach(function (opt, oi) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = String(oi + 1);
      btn.setAttribute('data-pp-btn', oi);
      btn.style.cssText =
        'width:26px;height:26px;display:flex;align-items:center;justify-content:center;' +
        'border-radius:6px;border:none;' +
        'font-size:11px;font-weight:600;cursor:pointer;transition:all 0.12s;' +
        'font-family:inherit;line-height:1;';
      stylePill(btn, oi === 0);
      btn.addEventListener('click', function () { doShow(pi, oi); });
      toolbar.appendChild(btn);
    });

    // Append drag grip after pills
    toolbar.appendChild(grip);

    pick.insertBefore(toolbar, pick.firstChild);
  });

  // Sliding highlight behind active pill
  var highlights = [];

  picks.forEach(function (pick, pi) {
    var toolbar = pick.querySelector('[data-pp-toolbar]');
    if (!toolbar) return;
    // Inner wrapper so highlight can be position:absolute without clobbering toolbar
    var inner = document.createElement('div');
    inner.style.cssText = 'position:relative;display:flex;align-items:center;gap:2px;';
    // Move all buttons into inner
    while (toolbar.firstChild) inner.appendChild(toolbar.firstChild);
    toolbar.appendChild(inner);

    var hl = document.createElement('div');
    hl.style.cssText =
      'position:absolute;top:0;left:0;width:26px;height:26px;' +
      'background:#18181b;border-radius:6px;' +
      'transition:transform 0.25s cubic-bezier(0.4,0,0.2,1);' +
      'pointer-events:none;';
    inner.insertBefore(hl, inner.firstChild);
    highlights[pi] = hl;

    // Measure pill offset after layout so highlight aligns with first pill
    (function (h, inn) {
      requestAnimationFrame(function () {
        var btn = inn.querySelector('[data-pp-btn]');
        if (btn) h.style.left = btn.offsetLeft + 'px';
      });
    })(hl, inner);
  });

  function moveHighlight(pi, oi) {
    var hl = highlights[pi];
    if (!hl) return;
    hl.style.transform = 'translateX(' + (oi * 28) + 'px)';
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
