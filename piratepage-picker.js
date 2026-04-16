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

    // PiratePage skull logo
    var logo = document.createElement('div');
    logo.innerHTML =
      '<svg width="14" height="14" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">' +
      '<path d="M25.4196 26.0918V31.2857H20.5313V28.8416C20.5313 28.0472 19.8591 27.375 19.0647 27.375C18.2704 27.375 17.5982 28.0472 17.5982 28.8416V31.2857H13.6875V28.8416C13.6875 28.0472 13.0153 27.375 12.221 27.375C11.4266 27.375 10.7545 28.0472 10.7545 28.8416V31.2857C10.7545 31.2857 8.87418 31.2857 5.86607 31.2857C5.86607 31.2857 5.86607 28.2503 5.86607 26.0918C2.32198 23.4031 0 19.3091 0 14.6652C0 6.59934 7.02714 0 15.6429 0C24.2586 0 31.2857 6.59934 31.2857 14.6652C31.2857 19.3091 29.0248 23.4031 25.4196 26.0918ZM5.86607 15.6429C5.86607 17.7815 7.63815 19.5536 9.77679 19.5536C11.9154 19.5536 13.6875 17.7815 13.6875 15.6429C13.6875 13.5042 11.9154 11.7321 9.77679 11.7321C7.63815 11.7321 5.86607 13.5042 5.86607 15.6429ZM21.5089 11.7321C19.3703 11.7321 17.5982 13.5042 17.5982 15.6429C17.5982 17.7815 19.3703 19.5536 21.5089 19.5536C23.6476 19.5536 25.4196 17.7815 25.4196 15.6429C25.4196 13.5042 23.6476 11.7321 21.5089 11.7321Z" fill="currentColor"/>' +
      '</svg>';
    logo.style.cssText =
      'flex-shrink:0;line-height:0;color:#18181b;' +
      'padding:0 4px 0 3px;pointer-events:none;';
    toolbar.appendChild(logo);

    // Divider between logo and pills
    var divider = document.createElement('div');
    divider.style.cssText = 'width:1px;height:16px;background:rgba(0,0,0,0.1);flex-shrink:0;';
    toolbar.appendChild(divider);

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
