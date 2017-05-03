# ============================================================================
# FILE: junkfile.py
# AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
# License: MIT license
# ============================================================================

from .base import Base
from time import strftime
import os


class Source(Base):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'junkfile'
        self.kind = 'file'

    def gather_candidates(self, context):
        self.vim.call('junkfile#init')
        base = self.vim.vars['junkfile#directory']

        candidates = []
        if context['args'] and context['args'][0] == 'new':
            context['is_interactive'] = True
            filename = strftime('%Y/%m/%Y-%m-%d-%H%M%S.') + context['input']
            candidates.append({
                'word': os.path.basename(filename),
                'abbr': '[new] ' + os.path.basename(filename),
                'action__path': os.path.join(base, filename),
            })
        else:
            for root, dirs, files in os.walk(base):
                for f in files:
                    candidates.append({
                        'word': f,
                        'action__path': os.path.join(root, f),
                    })
            candidates = sorted(candidates, key=lambda x:
                                os.path.getmtime(x['action__path']),
                                reverse=True)
        return candidates
