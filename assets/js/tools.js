// GigaTorq - Compare and Reviews tools. Both read /assets/data/tools.json (built from the database by build/tools_data.py).
(function () {
  var app = document.querySelector("[data-app]");
  if (!app) return;

  var DATA, BY = {};
  var IMG = "/assets/img/illustrations/web/";

  function esc(s) {
    return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }
  function fmt(n) { return Number(n).toLocaleString("en-US", { maximumFractionDigits: 2 }); }
  function singular(n) { return /(ches|shes)$/.test(n) ? n.slice(0, -2) : /s$/.test(n) ? n.slice(0, -1) : n; }
  function catName(t) { return DATA.categories[t.c] ? DATA.categories[t.c].name : t.c; }
  function title(t) { return t.b + " " + t.m; }
  function sameCat(c) { return DATA.tools.filter(function (t) { return t.c === c; }); }
  function band(v) {
    if (v < 50) return "Under $50";
    var step = v < 300 ? 50 : 100, lo = Math.floor(v / step) * step;
    return "$" + lo + "&ndash;" + (lo + step);
  }
  function priceTxt(t) {
    if (!t.price) return "";
    return band(t.price.usd) + ' <small>' + (t.price.what === "kit" ? "kit with battery and charger" : "tool only") + "</small>";
  }
  function ratingTxt(t) {
    if (!t.rating || !t.rating.avg) return "";
    return "<b>" + t.rating.avg.toFixed(1) + "</b> / 5" + (t.rating.count ? ' <small class="muted">(' + fmt(t.rating.count) + " reviews)</small>" : "");
  }
  function hasV(t) { return t.v && (t.p || "").indexOf(fmt(t.v) + "V") === -1; }
  function platform(t) {
    if (t.power === "corded") return "Corded";
    return esc(t.p || "") + (hasV(t) ? ' <small class="muted">(' + fmt(t.v) + "V)</small>" : "");
  }
  function motor(t) { return t.motor ? t.motor.charAt(0).toUpperCase() + t.motor.slice(1) : ""; }
  function thumb(t, cls) {
    return t.img ? '<img class="' + cls + '" src="' + IMG + t.img + '-800.jpg" width="800" height="450" alt="" loading="lazy" onerror="this.remove()">' : "";
  }
  function param(k) { return new URLSearchParams(location.search).get(k); }

  fetch(app.getAttribute("data-src")).then(function (r) { return r.json(); }).then(function (d) {
    DATA = d;
    d.tools.forEach(function (t) { BY[t.s] = t; });
    if (app.getAttribute("data-app") === "compare") compare(); else reviews();
  }).catch(function () {
    app.insertAdjacentHTML("beforeend", '<p class="placeholder">The tool list could not be loaded. Please refresh the page.</p>');
  });

  // ------------------------------------------------------------------ Compare
  function compare() {
    var sel = [document.getElementById("c1"), document.getElementById("c2"), document.getElementById("c3")];
    var out = document.getElementById("compare-out");
    var picks = [param("a"), param("b"), param("c")].map(function (s) { return BY[s] ? s : ""; });
    // the 2nd and 3rd picks must be the same type as the 1st, and all different
    if (!picks[0]) { picks = [picks[1] || picks[2] || "", "", ""]; }
    var cat = picks[0] ? BY[picks[0]].c : null;
    picks = picks.map(function (s, i) {
      if (!s || i === 0) return s;
      return BY[s].c === cat && picks.indexOf(s) === i ? s : "";
    });

    function fill() {
      cat = picks[0] ? BY[picks[0]].c : null;
      // first list: every tool, grouped by type
      var html = '<option value="">Choose a tool&hellip;</option>';
      Object.keys(DATA.categories).forEach(function (c) {
        var ts = sameCat(c);
        if (!ts.length) return;
        html += '<optgroup label="' + esc(DATA.categories[c].name) + '">' + ts.map(function (t) {
          return '<option value="' + t.s + '"' + (t.s === picks[0] ? " selected" : "") + ">" + esc(title(t)) + "</option>";
        }).join("") + "</optgroup>";
      });
      sel[0].innerHTML = html;
      // second and third lists: same type only, without the tools already chosen
      [1, 2].forEach(function (i) {
        var s = sel[i];
        if (!cat) { s.innerHTML = '<option value="">Pick the first tool</option>'; s.disabled = true; return; }
        var others = sameCat(cat).filter(function (t) { return picks.indexOf(t.s) === -1 || picks[i] === t.s; });
        if (!others.length) {
          s.innerHTML = '<option value="">No other ' + esc(singular(DATA.categories[cat].name).toLowerCase()) + "s in our database yet</option>";
          s.disabled = true; return;
        }
        s.disabled = false;
        s.innerHTML = '<option value="">' + (i === 1 ? "Choose a " : "Add a third ") + esc(singular(DATA.categories[cat].name).toLowerCase()) + "&hellip;</option>" +
          others.map(function (t) { return '<option value="' + t.s + '"' + (t.s === picks[i] ? " selected" : "") + ">" + esc(title(t)) + "</option>"; }).join("");
      });
    }

    function sync() {
      var q = ["a", "b", "c"].map(function (k, i) { return picks[i] ? k + "=" + picks[i] : ""; }).filter(Boolean).join("&");
      history.replaceState(null, "", location.pathname + (q ? "?" + q : ""));
      var chosen = picks.filter(Boolean).map(function (s) { return BY[s]; });
      if (chosen.length > 1) document.title = chosen.map(title).join(" vs ") + ": Specs Compared | GigaTorq";
    }

    sel.forEach(function (s, i) {
      s.addEventListener("change", function () {
        var v = s.value;
        if (i === 0 && v && cat && BY[v].c !== cat) { picks[1] = ""; picks[2] = ""; }
        picks[i] = v;
        if (i === 0 && !v) picks = ["", "", ""];
        if (i === 1 && !v) { picks[1] = picks[2]; picks[2] = ""; }
        fill(); sync(); render();
      });
    });

    function render() {
      var ts = picks.filter(Boolean).map(function (s) { return BY[s]; });
      if (!ts.length) { out.innerHTML = ""; return; }
      var c = DATA.categories[ts[0].c];
      var rows = [];

      // row(label, cells, numbers, higherIsBetter)
      function row(label, cells, nums, hib) {
        if (!cells.some(function (x) { return x; })) return;
        var best = null;
        if (nums && hib != null) {
          var v = nums.filter(function (x) { return x != null; });
          if (v.length > 1 && Math.max.apply(null, v) !== Math.min.apply(null, v)) best = hib ? Math.max.apply(null, v) : Math.min.apply(null, v);
        }
        rows.push("<tr><th>" + label + "</th>" + cells.map(function (x, i) {
          var win = best != null && nums[i] === best;
          return "<td" + (win ? ' class="winner"' : "") + ">" + (x || '<span class="muted">&ndash;</span>') + "</td>";
        }).join("") + "</tr>");
      }

      row("Price range", ts.map(priceTxt));
      row("Owner rating", ts.map(ratingTxt));
      row("Battery platform", ts.map(platform));
      row("Motor", ts.map(motor));
      c.specs.forEach(function (sp) {
        row(esc(sp.label), ts.map(function (t) { return esc(t.specs[sp.k] || ""); }),
          ts.map(function (t) { return t.nums[sp.k] != null ? t.nums[sp.k] : null; }), sp.hib);
      });
      row("Warranty", ts.map(function (t) { return esc(t.w || ""); }));
      row("Owners like", ts.map(function (t) { return t.likes.slice(0, 2).map(esc).join("<br>"); }));
      row("Owners complain", ts.map(function (t) { return t.gripes.slice(0, 2).map(esc).join("<br>"); }));
      row("Best for", ts.map(function (t) { return t.pick ? esc(t.pick.best_for) : ""; }));

      var head = ts.map(function (t) {
        return '<th class="cmp-head">' + thumb(t, "cmp-img") +
          (t.pick ? '<span class="tag">' + esc(t.pick.label) + "</span>" : "") +
          "<b>" + esc(title(t)) + '</b><small class="muted">' + esc(t.n) + "</small>" +
          '<a class="small" href="/reviews/' + t.s + '/">Full review &rarr;</a></th>';
      }).join("");
      var hint = ts.length === 1
        ? '<p class="muted">Now choose a second ' + esc(singular(c.name).toLowerCase()) + " to line them up.</p>" : "";
      var anyImg = ts.some(function (t) { return t.img; });
      out.innerHTML = hint + '<div class="table-wrap cmp-wrap"><table class="compare cmp cols-' + ts.length + '"><thead><tr><th class="cmp-corner">' +
        esc(c.name) + "</th>" + head + "</tr></thead><tbody>" + rows.join("") + "</tbody></table></div>" +
        '<p class="muted small">Green marks the best published spec in a row. Price ranges and owner ratings come from a major US retailer and change often.' +
        (anyImg ? " Pictures are AI illustrations made using photos of the real tools as a reference, not photos of the actual products." : "") + "</p>";
    }

    fill(); sync(); render();
  }

  // ------------------------------------------------------------------ Reviews search
  // Every tool has its own static page at /reviews/<slug>/; this box just finds it.
  function reviews() {
    var old = param("tool");  // links from before the static pages existed
    if (old && BY[old]) { location.replace("/reviews/" + old + "/"); return; }
    var q = document.getElementById("q");
    var list = document.getElementById("q-results");
    var active = -1, found = [];

    function norm(s) { return String(s).toLowerCase().replace(/[^a-z0-9]+/g, " ").trim(); }
    DATA.tools.forEach(function (t) {
      t._h = norm([t.b, t.m, t.m.replace(/[^a-z0-9]/gi, ""), t.n, catName(t), t.p, t.motor].join(" "));
    });

    function search(text) {
      var words = norm(text).split(" ").filter(function (w) { return w && !(w.length < 3 && /^\d+$/.test(w)); })
        .map(function (w) { return w.length > 3 && /s$/.test(w) && !/ss$/.test(w) ? w.slice(0, -1) : w; });
      if (!words.length) return [];
      return DATA.tools.map(function (t) {
        var score = 0, b = norm(t.b), m = norm(t.m);
        for (var i = 0; i < words.length; i++) {
          var w = words[i];
          if (t._h.indexOf(w) === -1) return null;
          score += m.indexOf(w) === 0 ? 4 : b.indexOf(w) === 0 ? 2 : 1;
        }
        return { t: t, score: score + (t.pick ? 0.5 : 0) };
      }).filter(Boolean).sort(function (a, b) { return b.score - a.score || title(a.t).localeCompare(title(b.t)); })
        .slice(0, 8).map(function (x) { return x.t; });
    }

    function showResults() {
      found = search(q.value);
      active = -1;
      if (!q.value.trim()) { list.hidden = true; list.innerHTML = ""; return; }
      list.innerHTML = found.length ? found.map(function (t, i) {
        return '<li role="option" id="r' + i + '"><a href="/reviews/' + t.s + '/">' + thumb(t, "res-img") +
          "<span><b>" + esc(title(t)) + "</b><small>" + esc(t.n) + " &middot; " + esc(catName(t)) + "</small></span></a></li>";
      }).join("") : '<li class="none">No tools match. Try a brand (Makita), a model number or a type (circular saw).</li>';
      list.hidden = false;
    }
    function highlight() {
      [].forEach.call(list.querySelectorAll("li"), function (li, i) { li.classList.toggle("on", i === active); });
    }

    q.addEventListener("input", showResults);
    q.addEventListener("focus", function () { if (q.value.trim()) showResults(); });
    q.addEventListener("keydown", function (e) {
      if (e.key === "ArrowDown" && found.length) { active = Math.min(active + 1, found.length - 1); highlight(); e.preventDefault(); }
      else if (e.key === "ArrowUp" && found.length) { active = Math.max(active - 1, 0); highlight(); e.preventDefault(); }
      else if (e.key === "Enter" && found.length) { location.href = "/reviews/" + found[Math.max(active, 0)].s + "/"; e.preventDefault(); }
      else if (e.key === "Escape") { list.hidden = true; }
    });
    document.addEventListener("click", function (e) { if (!e.target.closest(".search-box")) list.hidden = true; });
  }
})();