;;; clojure-cheatsheet.el --- The Clojure Cheatsheet for Emacs
;; Copyright 2013 Kris Jenkins

;; Author: Kris Jenkins <krisajenkins@gmail.com>
;; Maintainer: Kris Jenkins <krisajenkins@gmail.com>
;; Keywords: clojure nrepl cheatsheet helm
;; URL: https://github.com/krisajenkins/clojure-cheatsheet
;; Created: 7th August 2013
;; Version: 0.4.0
;; Package-Requires: ((helm "1.7.7") (cider "0.9.0")) ;; TODO Helm core?

;;; Commentary:
;;
;; A quick reference system for Clojure. Fast, searchable & available offline.

;;; Code:

(require 'helm)
(require 'helm-multi-match)
(require 'nrepl-client)
(require 'cider-interaction)
(require 'cl-lib)
(require 'cider-doc)

(defconst clojure-cheatsheet-hierarchy
  '(("Primitives"
     ("Numbers"
      ("Arithmetic"
       (clojure.core + - * / quot rem mod dec inc max min))
      ("Compare"
       (clojure.core = == not= < > <= >= compare))
      ("Bitwise"
       (clojure.core bit-and bit-and-not bit-clear bit-flip bit-not bit-or bit-set bit-shift-left bit-shift-right bit-test bit-xor unsigned-bit-shift-right))
      ("Cast"
       (clojure.core byte short long int float double bigdec bigint biginteger num rationalize))
      ("Test"
       (clojure.core nil? some? identical? zero? pos? neg? even? odd?))
      ("Random"
       (clojure.core rand rand-int))
      ("BigDecimal"
       (clojure.core with-precision))
      ("Ratios"
       (clojure.core numerator denominator ratio?))
      ("Arbitrary Precision Arithmetic"
       (clojure.core +\' -\' *\' inc\' dec\'))
      ("Unchecked"
       (clojure.core *unchecked-math*
                     unchecked-add
                     unchecked-add-int
                     unchecked-byte
                     unchecked-char
                     unchecked-dec
                     unchecked-dec-int
                     unchecked-divide-int
                     unchecked-double
                     unchecked-float
                     unchecked-inc
                     unchecked-inc-int
                     unchecked-int
                     unchecked-long
                     unchecked-multiply
                     unchecked-multiply-int
                     unchecked-negate
                     unchecked-negate-int
                     unchecked-remainder-int
                     unchecked-short
                     unchecked-subtract
                     unchecked-subtract-int)))

     ("Strings"
      ("Create"
       (clojure.core str format))
      ("Use"
       (clojure.core count get subs compare)
       (clojure.string join escape split split-lines replace replace-first reverse re-quote-replacement index-of last-index-of starts-with? ends-with? includes?))
      ("Regex"
       (:url "Java's Regex Syntax" "http://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html")
       (clojure.core re-find re-seq re-matches re-pattern re-matcher re-groups)
       (clojure.string replace replace-first re-quote-replacement))
      ("Letters"
       (clojure.string capitalize lower-case upper-case))
      ("Trim"
       (clojure.string trim trim-newline triml trimr))
      ("Test"
       (clojure.core char char? string?)
       (clojure.string blank?)))

     ("Other"
      ("Characters"
       (clojure.core char char-name-string char-escape-string))
      ("Keywords"
       (clojure.core keyword keyword? find-keyword))
      ("Symbols"
       (clojure.core symbol symbol? gensym))
      ("Data Readers"
       (clojure.core *data-readers* default-data-readers *default-data-reader-fn*))))

    ("Collections"
     ("Generic Ops"
      (clojure.core count empty not-empty into conj))
     ("Tree Walking"
      (clojure.walk walk prewalk prewalk-demo prewalk-replace postwalk postwalk-demo postwalk-replace keywordize-keys stringify-keys))
     ("Content tests"
      (clojure.core distinct? empty? every? not-every? some not-any?))
     ("Capabilities"
      (clojure.core sequential? associative? sorted? counted? reversible?))
     ("Type tests"
      (clojure.core type class coll? list? vector? set? map? seq?
                    number? integer? float? decimal? class? rational? ratio?
                    chunked-seq? reduced? special-symbol? record?))
     ("Lists"
      ("Create"
       (clojure.core list list*))
      ("Examine"
       (clojure.core first nth peek))
      ("'Change'"
       (clojure.core cons conj rest pop)))

     ("Vectors"
      ("Create"
       (clojure.core vec vector vector-of))
      ("Examine"
       (clojure.core get peek))

      ("'Change'"
       (clojure.core assoc pop subvec replace conj rseq))
      ("Ops"
       (clojure.core mapv filterv reduce-kv)))

     ("Sets"
      ("Create"
       (clojure.core set hash-set sorted-set sorted-set-by))
      ("Examine"
       (clojure.core get contains?))
      ("'Change'"
       (clojure.core conj disj))
      ("Relational Algebra"
       (clojure.set join select project union difference intersection))
      ("Get map"
       (clojure.set index rename-keys rename map-invert))
      ("Test"
       (clojure.set subset? superset?)))

     ("Maps"
      ("Create"
       (clojure.core hash-map array-map zipmap sorted-map sorted-map-by bean frequencies group-by))
      ("Examine"
       (clojure.core get get-in contains? find keys vals map-entry?))
      ("'Change'"
       (clojure.core assoc assoc-in dissoc merge merge-with select-keys update update-in))
      ("Entry"
       (clojure.core key val))
      ("Sorted Maps"
       (clojure.core rseq subseq rsubseq)))

     ("Hashes"
      (clojure.core hash hash-ordered-coll hash-unordered-coll mix-collection-hash))

     ("Volatiles"
      (clojure.core volatile! volatile? vreset! vswap!)))

    ("Functions"
     ("Create"
      (clojure.core fn defn defn- definline identity constantly comp complement partial juxt memfn memoize fnil every-pred some-fn trampoline))
     ("Call"
      (clojure.core -> ->> some-> some->> as-> cond-> cond->>))
     ("Test"
      (clojure.core fn? ifn?)))

    ("Transducers"
     ("Create"
      (clojure.core cat dedupe distinct drop drop-while filter interpose keep keep-indexed map map-indexed mapcat partition-all partition-by random-sample remove replace take take-nth take-while))
     ("Call"
      (clojure.core ->Eduction eduction into sequence transduce completing run!))
     ("Early Termination"
      (clojure.core deref reduced reduced? ensure-reduced unreduced)))

    ("Other"
     ("XML"
      (clojure.core xml-seq)
      (clojure.xml parse))
     ("REPL"
      (clojure.core *1 *2 *3 *e *print-dup* *print-length* *print-level* *print-meta* *print-readably*))
     ("EDN"
      (clojure.edn read read-string))
     ("Compiling Code & Class Generation"
      (:url "Documentation" "http://clojure.org/compilation")
      (clojure.core *compile-files* *compile-path* *file* *warn-on-reflection* compile gen-class gen-interface loaded-libs test))
     ("Misc"
      (clojure.core eval force name *clojure-version* clojure-version *command-line-args*))
     ("Pretty Printing"
      (clojure.pprint pprint print-table pp *print-right-margin*))
     ("Browser / Shell"
      (clojure.java.browse browse-url)
      (clojure.java.shell  sh with-sh-dir with-sh-env)))

    ("Vars & Global Environment"
     (:url "Documentation" "http://clojure.org/vars")
     ("Def Variants"
      (:special def)
      (clojure.core defn defn- definline defmacro defmethod defmulti defonce defrecord))
     ("Interned Vars"
      (:special var)
      (clojure.core declare intern binding find-var))
     ("Var Objects"
      (clojure.core with-local-vars var-get var-set alter-var-root var?))
     ("Var Validators"
      (clojure.core set-validator! get-validator)))

    ("Reader Conditionals"
     (clojure.core reader-conditional reader-conditional? tagged-literal tagged-literal?))

    ("Abstractions"
     ("Protocols"
      (:url "Documentation" "http://clojure.org/protocols")
      (clojure.core defprotocol extend extend-type extend-protocol reify extends? satisfies? extenders))
     ("Records & Types"
      (:url "Documentation" "http://clojure.org/datatypes")
      (clojure.core defrecord deftype))
     ("Multimethods"
      (:url "Documentation" "http://clojure.org/multimethods")
      ("Define"
       (clojure.core defmulti defmethod))
      ("Dispatch"
       (clojure.core get-method methods))
      ("Remove"
       (clojure.core remove-method remove-all-methods))
      ("Prefer"
       (clojure.core prefer-method prefers))
      ("Relation"
       (clojure.core derive isa? parents ancestors descendants make-hierarchy))))

    ("Macros"
     (:url "Documentation" "http://clojure.org/macros")
     ("Create"
      (clojure.core defmacro definline))
     ("Debug"
      (clojure.core macroexpand-1 macroexpand)
      (clojure.walk macroexpand-all))
     ("Branch"
      (clojure.core and or when when-not when-let when-first if-not if-let cond condp case))
     ("Loop"
      (clojure.core for doseq dotimes while))
     ("Arrange"
      (clojure.core .. doto ->))
     ("Scope"
      (clojure.core binding locking time)
      (clojure.core with-in-str with-local-vars with-open with-out-str with-precision with-redefs with-redefs-fn))
     ("Lazy"
      (clojure.core lazy-cat lazy-seq delay delay?))
     ("Doc."
      (clojure.core assert comment)
      (clojure.repl doc dir dir-fn source-fn)))

    ("Java Interop"
     (:url "Documentation" "http://clojure.org/java_interop")
     ("General"
      (:special new set!)
      (clojure.core .. doto bean comparator enumeration-seq import iterator-seq memfn definterface supers bases))
     ("Cast"
      (clojure.core boolean byte short char int long float double bigdec bigint num cast biginteger))
     ("Java Arrays"
      ("Create"
       (clojure.core boolean-array byte-array double-array char-array float-array int-array long-array make-array object-array short-array to-array))
      ("Manipulate"
       (clojure.core aclone aget aset alength amap areduce aset-int aset-long aset-short aset-boolean aset-byte aset-char aset-double aset-float))
      ("Cast"
       (clojure.core booleans bytes chars doubles floats ints longs shorts)))
     ("Exceptions"
      (:special throw try catch finally)
      (clojure.core ex-info ex-data Throwable->map)
      (clojure.repl pst)))

    ("Namespaces"
     (:url "Documentation" "http://clojure.org/namespaces")
     ("Current"
      (clojure.core *ns*))
     ("Create Switch"
      (clojure.core ns in-ns create-ns))
     ("Add"
      (clojure.core alias import intern refer refer-clojure))
     ("Find"
      (clojure.core all-ns find-ns))
     ("Examine"
      (clojure.core ns-aliases ns-imports ns-interns ns-map ns-name ns-publics ns-refers))
     ("From symbol"
      (clojure.core resolve namespace ns-resolve the-ns))
     ("Remove"
      (clojure.core ns-unalias ns-unmap remove-ns)))
    ("Loading"
     ("Load libs"
      (clojure.core require use import refer))
     ("List Loaded"
      (clojure.core loaded-libs))
     ("Load Misc"
      (clojure.core load load-file load-reader load-string)))

    ("Concurrency"
     (:url "Documentation" "http://clojure.org/atoms")
     ("Atoms"
      (clojure.core atom swap! reset! compare-and-set!))
     ("Futures"
      (clojure.core future future-call future-cancel future-cancelled? future-done? future?))
     ("Threads"
      (clojure.core bound-fn bound-fn* get-thread-bindings pop-thread-bindings push-thread-bindings))

     ("Misc"
      (clojure.core locking pcalls pvalues pmap seque promise deliver))

     ("Refs & Transactions"
      (:url "Documentation" "http://clojure.org/refs")
      ("Create"
       (clojure.core ref))
      ("Examine"
       (clojure.core deref))
      ("Transaction"
       (clojure.core sync dosync io!))
      ("In Transaction"
       (clojure.core ensure ref-set alter commute))
      ("Validators"
       (clojure.core get-validator set-validator!))
      ("History"
       (clojure.core ref-history-count ref-max-history ref-min-history)))

     ("Agents & Asynchronous Actions"
      (:url "Documentation" "http://clojure.org/agents")
      ("Create"
       (clojure.core agent))
      ("Examine"
       (clojure.core agent-error))
      ("Change State"
       (clojure.core send send-off restart-agent send-via set-agent-send-executor! set-agent-send-off-executor!))
      ("Block Waiting"
       (clojure.core await await-for))
      ("Ref Validators"
       (clojure.core get-validator set-validator!))
      ("Watchers"
       (clojure.core add-watch remove-watch))
      ("Thread Handling"
       (clojure.core shutdown-agents))
      ("Error"
       (clojure.core error-handler set-error-handler! error-mode set-error-mode!))
      ("Misc"
       (clojure.core *agent* release-pending-sends))))

    ("Sequences"
     ("Creating a Lazy Seq"
      ("From Collection"
       (clojure.core seq sequence keys vals rseq subseq rsubseq))
      ("From Producer Fn"
       (clojure.core lazy-seq repeatedly iterate))
      ("From Constant"
       (clojure.core repeat range))
      ("From Other"
       (clojure.core file-seq line-seq resultset-seq re-seq tree-seq xml-seq iterator-seq enumeration-seq))
      ("From Seq"
       (clojure.core keep keep-indexed)))

     ("Seq in, Seq out"
      ("Get shorter"
       (clojure.core distinct dedupe filter remove for))
      ("Get longer"
       (clojure.core cons conj concat lazy-cat mapcat cycle interleave interpose)))
     ("Tail-items"
      (clojure.core rest nthrest fnext nnext drop drop-while take-last for))
     ("Head-items"
      (clojure.core take take-nth take-while butlast drop-last for))
     ("'Change'"
      (clojure.core conj concat distinct flatten group-by partition partition-all partition-by split-at split-with filter remove replace shuffle random-sample))
     ("Rearrange"
      (clojure.core reverse sort sort-by compare))
     ("Process items"
      (clojure.core map pmap map-indexed mapcat for replace seque))

     ("Using a Seq"
      ("Extract item"
       (clojure.core first second last rest next ffirst nfirst fnext nnext nth nthnext rand-nth when-first max-key min-key))
      ("Construct coll"
       (clojure.core zipmap into reduce reductions set vec into-array to-array-2d))
      ("Pass to fn"
       (clojure.core apply))
      ("Search"
       (clojure.core some filter))
      ("Force evaluation"
       (clojure.core doseq dorun doall))
      ("Check for forced"
       (clojure.core realized?))))

    ("Zippers"
     ("Create"
      (clojure.zip zipper seq-zip vector-zip xml-zip))
     ("Get loc"
      (clojure.zip up down left right leftmost rightmost))
     ("Get seq"
      (clojure.zip lefts rights path children))
     ("'Change'"
      (clojure.zip make-node replace edit insert-child insert-left insert-right append-child remove))
     ("Move"
      (clojure.zip next prev))
     ("XML"
      (clojure.data.zip.xml attr attr= seq-test tag= text text= xml-> xml1->))
     ("Misc"
      (clojure.zip root node branch? end?)))

    ("Documentation"
     ("REPL"
      (clojure.repl doc find-doc apropos source pst)
      (clojure.java.javadoc javadoc)))

    ("Transients"
     (:url "Documentation" "http://clojure.org/transients")
     ("Create")
     (clojure.core transient persistent!)
     ("Change")
     (clojure.core conj! pop! assoc! dissoc! disj!))
    ("Misc"
     ("Compare"
      (clojure.core = == identical? not= not compare)
      (clojure.data diff))
     ("Test"
      (clojure.core true? false? nil? instance?)))

    ("IO"
     ("To/from ..."
      (clojure.core spit slurp))
     ("To *out*"
      (clojure.core pr prn print printf println newline)
      (clojure.pprint print-table))
     ("To writer"
      (clojure.pprint pprint cl-format))
     ("To string"
      (clojure.core format with-out-str pr-str prn-str print-str println-str))
     ("From *in*"
      (clojure.core read-line read))
     ("From reader"
      (clojure.core line-seq read))
     ("From string"
      (clojure.core read-string with-in-str))
     ("Open"
      (clojure.core with-open)
      (clojure.java.io reader writer input-stream output-stream))
     ("Interop"
      (clojure.java.io make-writer make-reader make-output-stream make-input-stream))
     ("Misc"
      (clojure.core flush file-seq *in* *out* *err*)
      (clojure.java.io file copy delete-file resource as-file as-url as-relative-path make-parents)))

    ("Metadata"
     (clojure.core meta with-meta alter-meta! reset-meta! vary-meta))

    ("Special Forms"
     (:url "Documentation" "http://clojure.org/special_forms")
     (:special def if do quote var recur throw try monitor-enter monitor-exit)
     (clojure.core fn loop)
     ("Binding / Destructuring"
      (clojure.core let fn letfn defn defmacro loop for doseq if-let if-some when-let when-some)))
    ("Async"
     ("Main"
      (clojure.core.async go go-loop <! <!! >! >!! chan put! take take! close! timeout offer! poll! promise-chan))
     ("Choice"
      (clojure.core.async alt! alt!! alts! alts!! do-alts))
     ("Buffering"
      (clojure.core.async buffer dropping-buffer sliding-buffer unblocking-buffer?))
     ("Pipelines"
      (clojure.core.async pipeline pipeline-async pipeline-blocking))
     ("Threading"
      (clojure.core.async thread thread-call))

     ("Mixing"
      (clojure.core.async admix solo-mode mix unmix unmix-all toggle merge pipe unique))
     ("Multiples"
      (clojure.core.async mult tap untap untap-all))
     ("Publish/Subscribe"
      (clojure.core.async pub sub unsub unsub-all))
     ("Higher Order"
      (clojure.core.async filter< filter> map map< map> mapcat< mapcat> partition partition-by reduce remove< remove> split))
     ("Pre-Populate"
      (clojure.core.async into onto-chan to-chan)))
    ("Unit Tests"
     ("Defining"
      (clojure.test deftest deftest- testing is are))
     ("Running"
      (clojure.test run-tests run-all-tests test-vars))
     ("Fixtures"
      (clojure.test use-fixtures join-fixtures compose-fixtures))))
  "A data structure designed for the maintainer's convenience, which we
transform into the format that helm requires.

It's a tree, where the head of each list determines the context of the rest of the list.
The head may be:

  A string, in which case it's a (sub)heading for the rest of the items.
  A symbol, in which case it's the Clojure namespace of the symbols that follow it.
  The keyword :special, in which case it's a Clojure special form - a symbol with no
  Any other keyword, in which case it's a typed item that will be passed
    through and handled in `clojure-cheatsheet/item-to-helm-source'.

Note that some many Clojure symbols appear in more than once. This is
entirely intentional. For instance, `map` belongs in the sections on
collections and transducers.")

;;; We could just make dash.el a dependency, but I'm not sure it's worth it for one utility macro.
(defmacro clojure-cheatsheet/->>
    (&rest body)
  (let ((result (pop body)))
    (dolist (form body result)
      (setq result (append (if (sequencep form)
                             form
                             (list form))
                           (list result))))))

(defun clojure-cheatsheet/treewalk
    (before after node)
  "Walk a tree.  Invoke BEFORE before the walk, and AFTER after it, on each NODE."
  (clojure-cheatsheet/->> node
                          (funcall before)
                          ((lambda (new-node)
                             (if (listp new-node)
                               (mapcar (lambda (child)
                                         (clojure-cheatsheet/treewalk before after child))
                                       new-node)
                               new-node)))
                          (funcall after)))

(defun clojure-cheatsheet/symbol-qualifier
    (namespace symbol)
  "Given a (Clojure) namespace and a symbol, fully-qualify that symbol."
  (intern (format "%s/%s" namespace symbol)))

(defun clojure-cheatsheet/string-qualifier
    (head subnode)
  (cond
   ((keywordp (car subnode)) (list head subnode))
   ((symbolp (car subnode)) (cons head subnode))
   ((stringp (car subnode)) (cons (format "%s : %s" head (car subnode))
                                  (cdr subnode)))
   (t (mapcar (apply-partially 'clojure-cheatsheet/string-qualifier head) subnode))))

(defun clojure-cheatsheet/propagate-headings
    (node)
  (clojure-cheatsheet/treewalk
   #'identity
   (lambda (item)
     (if (listp item)
       (cl-destructuring-bind (head &rest tail) item
         (cond ((equal :special head) tail)
               ((keywordp head) item)
               ((symbolp head) (mapcar (apply-partially #'clojure-cheatsheet/symbol-qualifier head) tail))
               ((stringp head) (mapcar (apply-partially #'clojure-cheatsheet/string-qualifier head) tail))
               (t item)))
       item))
   node))

(defun clojure-cheatsheet/flatten
    (node)
  "Flatten NODE, which is a tree structure, into a list of its leaves."
  (cond
   ((not (listp node)) node)
   ((keywordp (car node)) node)
   ((listp (car node)) (apply 'append (mapcar 'clojure-cheatsheet/flatten node)))
   (t (list (mapcar 'clojure-cheatsheet/flatten node)))))

(defun clojure-cheatsheet/group-by-head
    (data)
  "Group the DATA, which should be a list of lists, by the head of each list."
  (let ((result '()))
    (dolist (item data result)
      (let* ((head (car item))
             (tail (cdr item))
             (current (cdr (assoc head result))))
        (if current
          (setf (cdr (assoc head result))
                (append current tail))
          (setq result (append result (list item))))))))

(defun clojure-cheatsheet/lookup-doc
    (symbol)
  (if (cider-default-connection )
    (cider-doc-lookup symbol)
    (error "nREPL not connected!")))

(defun clojure-cheatsheet/lookup-src
    (symbol)
  (if (cider-default-connection )
    (cider-find-var nil symbol)
    (error "nREPL not connected!")))

(defun clojure-cheatsheet/item-to-helm-source
    (item)
  "Turn ITEM, which will be (\"HEADING\" candidates...), into a helm-source."
  (cl-destructuring-bind (heading &rest entries) item
    `((name . ,heading)
      (candidates ,@(mapcar (lambda (item)
                              (if (and (listp item)
                                       (keywordp (car item)))
                                (cl-destructuring-bind (kind title value) item
                                  (cons title
                                        (list kind value)))
                                item))
                            entries))
      (match . ((lambda (candidate)
                  (helm-mm-3-match (format "%s %s" candidate ,heading)))))
      (action-transformer (lambda (action-list current-selection)
                            (if (and (listp current-selection)
                                     (eq (car current-selection) :url))
                              '(("Browse" . (lambda (item)
                                              (helm-browse-url (cadr item)))))
                              '(("Lookup Docs" . clojure-cheatsheet/lookup-doc)
                                ("Lookup Source" . clojure-cheatsheet/lookup-src))))))))

(defvar helm-source-clojure-cheatsheet
  (clojure-cheatsheet/->> clojure-cheatsheet-hierarchy
                          clojure-cheatsheet/propagate-headings
                          clojure-cheatsheet/flatten
                          clojure-cheatsheet/group-by-head
                          (mapcar 'clojure-cheatsheet/item-to-helm-source)))

;;;###autoload
(defun clojure-cheatsheet ()
  "Use helm to show a Clojure cheatsheet."
  (interactive)
  (helm :sources helm-source-clojure-cheatsheet))

(provide 'clojure-cheatsheet)

;;; clojure-cheatsheet.el ends here
